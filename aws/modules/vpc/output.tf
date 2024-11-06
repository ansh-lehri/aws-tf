output "vpc-id" {
    description = "id of vpc created"
    value = aws_vpc.vpc.id
}