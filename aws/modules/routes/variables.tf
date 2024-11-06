variable "vpc_id" {
    type = string
}

variable "route_tables" {
    type = list(object({
        name = string
        tags = map(string)
        routes = list(object({
            destination_cidr = string
            target = string
        }))
        associated_subnet_names = list(string)
    }))
}

variable "subnet_ids" {
    type = map(string)
}

variable "target_ids" {
    type = map(string)
}