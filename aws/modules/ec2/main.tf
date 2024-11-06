resource "aws_instance" "ec2" {
    for_each = var.ec2-instances

    ami = each.value.ami
    associate_public_ip_address = each.value.associate_public_ip_address
    availability_zone = each.value.zone
    instance_type = each.value.instance_type
    tags = each.value.tags
    subnet_id = each.value.subnet_id
    vpc_security_group_ids = each.value.vpc_security_group_ids
    key_name = each.value.key_name
}


resource "null_resource" "ec2-bootstrap"{
    for_each = var.ec2-instances

    provisioner "local-exec" {
        command = "git clone https://${var.github_username}:${var.github_pat}@github.com/${var.github_username}/${each.value.bootstrap_scripts.git_repo}.git"
        environment = {
            GIT_REPO = each.value.bootstrap_scripts.git_repo
        }
    }

    connection {
        type     = "ssh"
        user     = "ubuntu"
        private_key = file("${var.dir_path_to_login_keys}/${each.value.key_name}.pem")
        host     = aws_instance.ec2[each.key].public_ip
    }

    provisioner "file" {
        source = "${each.value.bootstrap_scripts.git_repo}/${each.value.bootstrap_scripts.folder_path}/${each.value.bootstrap_scripts.script_name}"
        destination = "/home/ubuntu/${each.value.bootstrap_scripts.script_name}"
    }

    provisioner "remote-exec" {
        inline = [
            "export AWS_ACCESS_KEY_ID=${var.aws_access_key_id}",
            "export AWS_ACCESS_SECRET_KEY=${var.aws_access_secret_key}",
            "sudo chmod +x /home/ubuntu/${each.value.bootstrap_scripts.script_name}",
            "./${each.value.bootstrap_scripts.script_name}"
        ]
    }
}