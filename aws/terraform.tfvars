terraform_backend_config = {
    bucket_name = "rattle"
    path_to_tfstate_file = "aws/tfstate"
    bucket_region = "ap-south-1"
    encryption = false
}


network_layer = {
    region = "ap-south-1"
    vpc = {
        cidr = "10.0.0.0/16"
        tags = {
            "Name": "rattle-vpc"
        }
    }
    internet_gateway = {
      tags = {
        "Name": "rattle-ig"
      }
    }
    subnets = [
        {
            availability_zone = "ap-south-1a"
            cidr_block = "10.0.1.0/24"
            name = "rattle-pub-1a"
            tags = {
                "Name" = "rattle-pub-1a"
            }
        },
        {
            availability_zone = "ap-south-1b"
            cidr_block = "10.0.3.0/24"
            name = "rattle-pub-1b"
            tags = {
                "Name" = "rattle-pub-1b"
            }
        },
        {
            availability_zone = "ap-south-1c"
            cidr_block = "10.0.5.0/24"
            name = "rattle-pub-1c"
            tags = {
                "Name" = "rattle-pub-1c"
            }
        },
        {
            availability_zone = "ap-south-1a"
            cidr_block = "10.0.2.0/24"
            name = "rattle-pvt-1a"
            tags = {
                "Name" = "rattle-pvt-1a"
            }
        },
        {
            availability_zone = "ap-south-1b"
            cidr_block = "10.0.4.0/24"
            name = "rattle-pvt-1b"
            tags = {
                "Name" = "rattle-pvt-1b"
            }
        },
        {
            availability_zone = "ap-south-1c"
            cidr_block = "10.0.6.0/24"
            name = "rattle-pvt-1c"
            tags = {
                "Name" = "rattle-pvt-1c"
            }
        }
    ]
    nat_gateway = {
      connectivity_type = "public"
      nat_subnet_name = "rattle-pub-1a"
      tags = {
        "Name": "rattle_nat_gateway"
      }
    }

    route_tables = [
        {
            associated_subnet_names = ["rattle-pub-1a","rattle-pub-1b","rattle-pub-1c"]
            name = "rattle-pub-rt"
            routes = [ 
                {
                    destination_cidr = "0.0.0.0/0"
                    target = "internet_gateway"
                } 
            ]
            tags = {
                "Name" = "rattle-pub"
            }
        },
        {
            associated_subnet_names = ["rattle-pvt-1a","rattle-pvt-1b","rattle-pvt-1c"]
            name = "rattle-pvt-rt"
            routes = [ 
                {
                    destination_cidr = "0.0.0.0/0"
                    target = "nat_gateway"
                } 
            ]
            tags = {
                "Name" = "rattle-pvt"
            }
        }
    ]
}


security_groups = [
    {
        name = "rattel-bastion-sg"
        tags = {
            "Name": "rattle-bastion-sg"
        }
        ingress_rules = [
            {
                from_port = -1
                to_port = -1
                protocol = "icmp"
                cidr_blocks = ["0.0.0.0/0"]
            },
            {
                from_port = 22
                to_port = 22
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
            }
        ]
        egress_rules = [
            {
                from_port = 0
                to_port = 0
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
            }
        ]
    },
    {
        name = "rattel-eks-sg"
        tags = {
            "Name": "rattle-eks-sg"
        }
        ingress_rules = [
            {
                from_port = -1
                to_port = -1
                protocol = "icmp"
                cidr_blocks = ["0.0.0.0/0"]
            },
            {
                from_port = 0
                to_port = 80
                protocol = "tcp"
                cidr_blocks = ["10.0.0.0/16"]
            }
        ]
        egress_rules = [
            {
                from_port = 0
                to_port = 0
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
            }
        ]
    },
    {
        name = "rattle-eks-sg"
        tags = {
            "Name": "rattle-eks-sg"
        }
        ingress_rules = [
            {
                from_port = -1
                to_port = -1
                protocol = "icmp"
                cidr_blocks = ["0.0.0.0/0"]
            },
            {
                from_port = 0
                to_port = 80
                protocol = "tcp"
                cidr_blocks = ["10.0.0.0/16"]
            }
        ]
        egress_rules = [
            {
                from_port = 0
                to_port = 0
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
            }
        ]
    },
    {
        name = "rattel-eks-ng-sg"
        tags = {
            "Name": "rattle-eks-ng-sg"
        }
        ingress_rules = [
            {
                from_port = -1
                to_port = -1
                protocol = "icmp"
                cidr_blocks = ["0.0.0.0/0"]
            },
            {
                from_port = 0
                to_port = 80
                protocol = "tcp"
                cidr_blocks = ["10.0.0.0/16"]
            },
            {
                from_port = 0
                to_port = 443
                protocol = "tcp"
                cidr_blocks = ["10.0.0.0/16"]
            }
        ]
        egress_rules = [
            {
                from_port = 0
                to_port = 0
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
            }
        ]
    },
    {
        name = "rattle-eks-ng-sg"
        tags = {
            "Name": "rattle-eks-ng-sg"
        }
        ingress_rules = [
            {
                from_port = -1
                to_port = -1
                protocol = "icmp"
                cidr_blocks = ["0.0.0.0/0"]
            },
            {
                from_port = 0
                to_port = 80
                protocol = "tcp"
                cidr_blocks = ["10.0.0.0/16"]
            },
            {
                from_port = 0
                to_port = 443
                protocol = "tcp"
                cidr_blocks = ["10.0.0.0/16"]
            }
        ]
        egress_rules = [
            {
                from_port = 0
                to_port = 0
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
            }
        ]
    }
    
]

ec2-instances = [
    {
        ami_id = "ami-0dee22c13ea7a9a67"
        instance_type = "t2.micro"
        name = "rattle-bastion"
        public_ip_association = true
        secruity_group_names = [ "rattel-bastion-sg" ]
        tags = {
            "Name" = "rattle-bastion"
        }
        zone = "ap-south-1a"
        instance_subnet_name = "rattle-pub-1a"
        login-key-name = "test-rattle-1"
        bootstrap_scripts = {
            git_repo = "flask-hello-world"
            folder_path = "/"
            script_name = "bastion-bootstrap.sh"
        }
    }
]

eks_clusters = [
    {
        control_plane = {
            name = "rattle-eks"
            role_arn = "arn:aws:iam::851725241491:role/rattle-cluster"
            vpc_config = {
                cluster_endpoint_access = "private"
                security_group_names = ["rattle-eks-sg"]
                associated_subnet_names = ["rattle-pub-1a","rattle-pub-1b","rattle-pub-1c"]
            }
            access_config = {
                authentication_mode = "API"
            }
            kubernetes_network_config = {
                service_ipv4_cidr = "172.20.0.0/24"
                ip_family = "ipv4"
            }
            version = "1.31"
        }
        node_groups = [
            {
                name = "rattle-ng-1"
                role_arn = "arn:aws:iam::851725241491:role/rattle-ng"
                scaling_config = {
                    max_size = 2
                    min_size = 1
                    desired_size = 1
                }
                remote_access = {
                    login-key-name = "test-rattle-1"
                    security_group_names = ["rattle-eks-ng-sg"]
                }
                associated_subnet_names = ["rattle-pvt-1a","rattle-pvt-1b"]
                ami_type = "AL2_x86_64"
                capacity_type = "SPOT"
                instance_type = ["t3.medium"]
                labels = {
                    "cluster": "rattle"
                }
                version = "1.31"
                taint = {
                    key = "test-cluster-owner"
                    value = "rattle"
                    effect = "NO_SCHEDULE"
                }
            }
        ]
    }
]

bastion_cluster_connect = {
    create_connect = true
    bastion_name = "rattle-bastion"
    bastion_user = "ubuntu"
    security_group_name_to_open_ports = "rattle-eks-sg"
    login-key-name = "test-rattle-1"
    login-key-path = "/Users/ansh.lehri/desktop/login-keys"
    clusters = [
        {
            cluster_name = "rattle-eks"
            region = "ap-south-1"
        }
    ]
}