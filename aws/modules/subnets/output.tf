output "subnet_ids" {
    value = { for name, subnet_info in var.subnets : name => aws_subnet.subnet[name].id }
    description = "dictionary of subnet name and its id"
}