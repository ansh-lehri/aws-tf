variable "subnets" {
    type = map(object({
        availability_zone = string
        cidr_block = string
        tags = map(string)
    }))
}

variable "vpc_id" {
    type = string
}