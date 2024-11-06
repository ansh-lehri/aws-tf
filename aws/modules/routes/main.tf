locals {
  route_tables = {
    for route_table in var.route_tables : route_table.name => {
        routes = zipmap(
            [ for i in range(length(route_table.routes)) : tostring(i)],
            route_table.routes
        )
        tags = route_table.tags
    }
  }
  route_table_subnet_association = flatten([
    for route_table in var.route_tables : [
      for subnet_name in route_table.associated_subnet_names : {
        subnet_id = var.subnet_ids[subnet_name]
        route_table_id = aws_route_table.route_table[route_table.name].id
      }
    ]
  ])
}


resource "aws_route_table" "route_table" {
    for_each = local.route_tables
    
    vpc_id = var.vpc_id
    tags = each.value.tags

    dynamic "route" {
        for_each = each.value.routes
        content {
          cidr_block = route.value.destination_cidr
          nat_gateway_id  = route.value.target == "nat_gateway" ? var.target_ids[route.value.target] : null
          gateway_id  = route.value.target == "internet_gateway" ? var.target_ids[route.value.target] : null
        } 
    }
}

resource "aws_route_table_association" "route_table_association" {
    for_each = { for subnet_id, route_table_id in local.route_table_subnet_association : subnet_id => route_table_id  }

    subnet_id = each.value.subnet_id
    route_table_id = each.value.route_table_id
}