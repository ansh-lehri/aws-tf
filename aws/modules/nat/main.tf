resource "aws_nat_gateway" "nat" {
    allocation_id = var.eip_association
    subnet_id = var.nat_gateway.subnet_id
    connectivity_type = var.nat_gateway.connectivity_type
    tags = var.nat_gateway.tags
  
}