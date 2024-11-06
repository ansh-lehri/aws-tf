resource "aws_eks_cluster" "eks" {
    for_each = var.eks_clusters

    name = each.key
    role_arn = each.value.role_arn
    
    vpc_config {
      endpoint_private_access = each.value.vpc_config.endpoint_private_access
      endpoint_public_access = each.value.vpc_config.endpoint_public_access
      security_group_ids = each.value.vpc_config.security_group_ids
      subnet_ids = each.value.vpc_config.subnet_ids
    }

    access_config {
        authentication_mode = each.value.access_config.authentication_mode
    }

    kubernetes_network_config{
        service_ipv4_cidr = each.value.kubernetes_network_config.service_ipv4_cidr
        ip_family = each.value.kubernetes_network_config.ip_family
    }

    version = each.value.version
}


resource "aws_eks_node_group" "node_groups" {
    for_each = { for node_group in var.node_groups : node_group.node_group_name => node_group }

    node_group_name = each.key
    cluster_name = each.value.cluster_name
    node_role_arn = each.value.role_arn

    scaling_config {
      desired_size = each.value.scaling_config.desired_size
      min_size = each.value.scaling_config.min_size
      max_size = each.value.scaling_config.max_size
    }

    remote_access {
        ec2_ssh_key = each.value.remote_access.ec2_ssh_key
        source_security_group_ids = each.value.remote_access.source_security_group_ids
    }

    subnet_ids = each.value.subnet_ids
    ami_type = each.value.ami_type
    capacity_type = each.value.capacity_type
    instance_types = each.value.instance_type
    labels = each.value.labels
    version = each.value.version
    
    taint {
        key = each.value.taint.key
        value = each.value.taint.value
        effect = each.value.taint.effect
    }

    depends_on = [ aws_eks_cluster.eks ]
}