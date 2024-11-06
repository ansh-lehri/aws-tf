# output "route-table-id" {
#   value = { 
#     for key, route in var.route_tables : key =>  aws_route_table.route_table[key].id
#     }
# }