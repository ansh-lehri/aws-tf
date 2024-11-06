locals {
    region = var.network_layer.region
    vpc = var.network_layer.vpc
    internet_gateway_tags = var.network_layer.internet_gateway.tags
    subnets = {
        for subnet in var.network_layer.subnets : subnet.name => 
            {
                availability_zone = subnet.availability_zone
                cidr_block = subnet.cidr_block
                tags = subnet.tags
            }
    }
    nat_gateway = merge(var.network_layer.nat_gateway, {"subnet_id": module.subnet.subnet_ids[var.network_layer.nat_gateway.nat_subnet_name] })

    gateway_ids = {
        "internet_gateway" = module.ig.ig-id
        "nat_gateway" = module.nat.nat-id
  }

  security_groups = {
    for sg in var.security_groups : sg.name => {
        tags = sg.tags
        ingress_rules = zipmap(
            [ for idx, rule in sg.ingress_rules : idx ],
            sg.ingress_rules
        )
        egress_rules = zipmap(
            [ for idx, rule in sg.egress_rules : idx ],
            sg.egress_rules
        )
    }
  }

  ec2_instances = {
    for ec2 in var.ec2-instances : ec2.name => {
        ami = ec2.ami_id
        instance_type = ec2.instance_type
        tags = ec2.tags
        associate_public_ip_address = ec2.public_ip_association
        zone = ec2.zone
        vpc_security_group_ids = [
            for sg in ec2.secruity_group_names : module.security_groups.security_groups[sg]
        ]
        subnet_id = module.subnet.subnet_ids[ec2.instance_subnet_name]
        key_name = ec2.login-key-name
        bootstrap_scripts = ec2.bootstrap_scripts
    }
  }
  
  eks_clusters = {
    for eks in var.eks_clusters : eks.control_plane.name => {
        role_arn = eks.control_plane.role_arn
        access_config = eks.control_plane.access_config
        kubernetes_network_config = eks.control_plane.kubernetes_network_config
        version = eks.control_plane.version
        vpc_config = {
            endpoint_private_access = true ? eks.control_plane.vpc_config.cluster_endpoint_access == "private" : false
            endpoint_public_access = true ? eks.control_plane.vpc_config.cluster_endpoint_access == "public" : false
            security_group_ids = [ 
                for sg in eks.control_plane.vpc_config.security_group_names : module.security_groups.security_groups[sg]
            ]
            subnet_ids = [
                for subnet in eks.control_plane.vpc_config.associated_subnet_names : module.subnet.subnet_ids[subnet]
            ]
        }
    }
  }

  node_groups = flatten([
    for eks in var.eks_clusters : [
        for node_group in eks.node_groups : {
            cluster_name = eks.control_plane.name
            role_arn = node_group.role_arn
            node_group_name = node_group.name
            scaling_config = node_group.scaling_config
            remote_access = {
                ec2_ssh_key = node_group.remote_access.login-key-name
                source_security_group_ids = [
                    for sg in node_group.remote_access.security_group_names : module.security_groups.security_groups[sg]
                ]
            }
            subnet_ids = [
                for subnet in node_group.associated_subnet_names : module.subnet.subnet_ids[subnet]
            ]
            ami_type = node_group.ami_type
            capacity_type = node_group.capacity_type
            instance_type = node_group.instance_type
            labels = node_group.labels
            version = node_group.version
            taint = node_group.taint
        }
    ]
  ])

  bastion_cluster_connect = {
        host = module.ec2.ec2-instances-ip[var.bastion_cluster_connect.bastion_name]
        bastion_pvt_ip = module.ec2.ec2-instances-pvt-ip[var.bastion_cluster_connect.bastion_name]
        user = var.bastion_cluster_connect.bastion_user
        security_group_id = module.security_groups.security_groups[var.bastion_cluster_connect.security_group_name_to_open_ports]
        login-key-name = var.bastion_cluster_connect.login-key-name
        login-key-path = var.bastion_cluster_connect.login-key-path
        clusters = {
            for cluster in var.bastion_cluster_connect.clusters : cluster.cluster_name => cluster.region
        }
  }
}


terraform {
  backend "s3" {
    bucket = var.terraform_backend_config.bucket_name
    key    = var.terraform_backend_config.path_to_tfstate_file
    region = var.terraform_backend_config.bucket_region
    encrypt = var.terraform_backend_config.encryption                   
  }
}


provider "aws" {
    region = local.region
}

module "vpc" {
    source = "./modules/vpc"
    vpc = local.vpc
}

module "ig" {
    source = "./modules/ig"
    vpc_id = module.vpc.vpc-id
    tags = local.internet_gateway_tags
}

module "subnet" {
    source = "./modules/subnets"
    subnets = local.subnets
    vpc_id = module.vpc.vpc-id
}

resource "aws_eip" "eip" {
    domain = "vpc"
}

module "nat" {
    source = "./modules/nat"
    nat_gateway = local.nat_gateway
    eip_association = resource.aws_eip.eip.id
}

module "route" {
    source = "./modules/routes"
    route_tables = var.network_layer.route_tables
    target_ids = local.gateway_ids
    vpc_id = module.vpc.vpc-id
    subnet_ids = module.subnet.subnet_ids
}

module "security_groups" {
    source = "./modules/securitygroups"
    security_groups = local.security_groups
    vpc_id = module.vpc.vpc-id
}

module "ec2" {
    source = "./modules/ec2"
    ec2-instances = local.ec2_instances
    aws_access_key_id = var.aws_access_key_id
    aws_access_secret_key = var.aws_access_secret_key
    github_pat = var.github_pat
    github_username = var.github_username
}

module "eks" {
    source = "./modules/eks"
    eks_clusters = local.eks_clusters
    node_groups = local.node_groups
}


module "bastion-setup" {
    count = var.bastion_cluster_connect.create_connect ? 1 : 0
    source = "./modules/bastion-setup"
    bastion_cluster_connect = local.bastion_cluster_connect
}