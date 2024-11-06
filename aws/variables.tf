variable "terraform_backend_config" {
    type = object({
      bucket_name = string
      path_to_tfstate_file = string
      bucket_region = string
      encryption = bool
    })
}


variable "aws_access_key_id" {
    type = string
}

variable "aws_access_secret_key" {
    type = string
}

variable "github_pat" {
  type = string
}

variable "github_username" {
  type = string
}

variable "network_layer" {
    type = object({
        region = string
        vpc = object({
            cidr = string
            tags = map(string)
        })
        internet_gateway = object({
          tags = map(string)
        })
       subnets = list(object({
            name = string
            availability_zone = string
            cidr_block = string
            tags = map(string)
       }))
       nat_gateway = object({
         connectivity_type = string
         nat_subnet_name = string
         tags = map(string)
       })
       route_tables = list(object({
         name = string
         tags = map(string)
         routes = list(object({
          destination_cidr = string
          target = string
         }))
         associated_subnet_names = list(string)
       }))
    })
}


variable "security_groups" {

    type = list(object({
      name = string
      tags = map(string)
      ingress_rules = list(object({
        from_port = number
        to_port = number
        protocol = string
        cidr_blocks = list(string)
      }))
      egress_rules = list(object({
        from_port = number
        to_port = number
        protocol = string
        cidr_blocks = list(string)
      }))
    }))
}

variable "ec2-instances" {

    type = list(object({
      name = string
      ami_id = string
      instance_type = string
      tags = map(string)
      secruity_group_names = list(string)
      public_ip_association = bool
      zone = string
      instance_subnet_name = string
      login-key-name = string
      bootstrap_scripts = object({
        git_repo = string
        folder_path = string
        script_name = string
      })
    }))
}

variable "eks_clusters" {

  type = list(object({
      control_plane = object({
        name = string
        role_arn = string
        vpc_config = object({
          cluster_endpoint_access = string
          security_group_names = list(string)
          associated_subnet_names = list(string)
        }) 
        access_config = object({
          authentication_mode = string
        })
        kubernetes_network_config = object({
          service_ipv4_cidr = string
          ip_family = string
        })
        version = string
      })
      node_groups = list(object({
        name = string
        role_arn = string
        scaling_config = map(number)
        remote_access = object({
          login-key-name = string
          security_group_names = list(string)
        })
        associated_subnet_names = list(string)
        ami_type = string
        capacity_type = string
        instance_type = list(string)
        labels = map(string)
        version = string
        taint = object({
          key = string
          value = string
          effect = string 
        })
      }))
  })) 
}

variable "bastion_cluster_connect" {
    type = object({
      create_connect = bool
      bastion_name = string
      bastion_user = string
      security_group_name_to_open_ports = string
      login-key-name = string
      login-key-path = string
      clusters = list(object({
        cluster_name = string
        region = string
      }))
    })
  
}