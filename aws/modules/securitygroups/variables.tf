variable "security_groups" {
    type = map(object({
        tags = map(string)
        ingress_rules = map(object({
            from_port = number
            to_port = number
            protocol = string
            cidr_blocks = list(string)
        }))
        egress_rules = map(object({
            from_port = number
            to_port = number
            protocol = string
            cidr_blocks = list(string)
        }))
    }))
}

variable "vpc_id" {
    type = string
  
}