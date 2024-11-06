terraform {
  backend "s3" {
    bucket = var.terraform_backend_config.bucket_name
    key    = var.terraform_backend_config.path_to_tfstate_file
    region = var.terraform_backend_config.bucket_region
    encrypt = var.terraform_backend_config.encryption                   
  }
}



provider "aws" {
    region = var.cicd_server_config.region
}

resource "null_resource" "cicd" {
    connection {
        type     = "ssh"
        user     = var.cicd_server_config.user
        private_key = file("${var.cicd_server_config.dir_path_to_login_keys}/${var.cicd_server_config.login-key-name}.pem")
        host     = var.cicd_server_config.ip
    }

    triggers = {
      repos_to_build = join(",",[ for repo_to_build in var.repos_to_build_and_deploy : repo_to_build.image.version ])
      name = join(",",[ for repo_to_build in var.repos_to_build_and_deploy : repo_to_build.image.name ])
    }

    for_each = { 
        for repo_to_build in var.repos_to_build_and_deploy : repo_to_build.code_git_repo => 
        {
            dockerfile_path = repo_to_build.dockerfile_path
            image = repo_to_build.image
        }
    }

    provisioner "remote-exec" {
        inline = [
            "git clone https://${var.github_username}:${var.github_pat}@github.com/${var.github_username}/${each.key}.git",
            "cd ${each.key}",
            "ls",
            "sudo docker build -t ${each.value.image.registry}/${each.value.image.name}:${each.value.image.version} .",
            "sudo docker login --username ${var.docker_config_username} --password ${var.docker_config_password}",
            "sudo docker push ${each.value.image.registry}/${each.value.image.name}:${each.value.image.version}",
            "cd ..",
            "sudo rm -rf ${each.key}"
        ]
      
    }
}


resource "null_resource" "cicd-deploy" {

    depends_on = [ null_resource.cicd ]

    connection {
        type     = "ssh"
        user     = var.cicd_server_config.user
        private_key = file("${var.cicd_server_config.dir_path_to_login_keys}/${var.cicd_server_config.login-key-name}.pem")
        host     = var.cicd_server_config.ip
    }

    triggers = {
      repos_to_build_and_deploy = join(",",[ for repo_to_build in var.repos_to_build_and_deploy : repo_to_build.image.version ])
      name = join(",",[ for repo_to_build in var.repos_to_build_and_deploy : repo_to_build.image.name ])
    }

    for_each = { 
        for repo_to_deploy in var.repos_to_build_and_deploy : repo_to_deploy.team_name => 
        {
            service_name = repo_to_deploy.code_git_repo
            image = repo_to_deploy.image
        }
    }

    provisioner "remote-exec" {
        inline = [
            "sudo git clone https://${var.github_username}:${var.github_pat}@github.com/${var.github_username}/${each.key}-deploy.git",
            "cd ${each.key}-deploy/${each.value.service_name}",
            "ls",
            "sudo sed -i 's|${each.value.image.name}:.*|${each.value.image.name}:${each.value.image.version}|' deployment.yaml",
            "kubectl apply -f .",
            "cd ..",
            "sudo rm -rf ${each.key}-deploy.git"
        ]
      
    }
}