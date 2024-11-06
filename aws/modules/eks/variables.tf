variable "eks_clusters" {
    type = map(object({
        role_arn = string
        access_config = object({
          authentication_mode = string
        })
        kubernetes_network_config = object({
          service_ipv4_cidr = string
          ip_family = string
        })
        version = string
        vpc_config = object({
          endpoint_private_access = bool
          endpoint_public_access = bool
          security_group_ids = list(string)
          subnet_ids = list(string)
        })
    }))
}

variable "node_groups" {
    type = list(object({
        node_group_name = string
        cluster_name = string
        role_arn = string
        remote_access = object({
            ec2_ssh_key = string
            source_security_group_ids = list(string)
        })
        scaling_config = map(number)
        subnet_ids = list(string)
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
}