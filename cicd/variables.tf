variable "terraform_backend_config" {
    type = object({
      bucket_name = string
      path_to_tfstate_file = string
      bucket_region = string
      encryption = bool
    })
}


variable "cicd_server_config" {
    type = object({
        region = string
        ip = string
        login-key-name = string
        dir_path_to_login_keys = string
        user = string
    })
}

variable "docker_config_username" {
  type = string
}

variable "docker_config_password" {
  type = string
}

variable "github_pat" {
  type = string
}

variable "github_username" {
  type = string
}


variable "repos_to_build_and_deploy" {
    type = list(object({
        code_git_repo = string
        dockerfile_path = string
        image = object({
          name = string
          registry = string
          version = string
        })
        team_name = string
    }))
}