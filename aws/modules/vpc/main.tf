resource "aws_vpc" "vpc" {
    cidr_block = var.vpc.cidr
    tags = var.vpc.tags
}