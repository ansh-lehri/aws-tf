variable "nat_gateway" {
  type = object({
    connectivity_type = string
    subnet_id = string
    nat_subnet_name = string
    tags = map(string) 
  })
}

variable "eip_association" {
    type = string
}