output "ec2-instances-id" {
    value = {
        for ec2_name, config in var.ec2-instances : ec2_name => aws_instance.ec2[ec2_name].id
    }
  
}


output "ec2-instances-ip" {
    value = {
        for ec2_name, config in var.ec2-instances : ec2_name => aws_instance.ec2[ec2_name].public_ip
    }
  
}

output "ec2-instances-pvt-ip" {
    value = {
        for ec2_name, config in var.ec2-instances : ec2_name => aws_instance.ec2[ec2_name].private_ip
    }
  
}