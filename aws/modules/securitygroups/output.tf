output "security_groups" {
    value = {
        for sg_name, sg_info in var.security_groups : sg_name => aws_security_group.security_group[sg_name].id
    }
}