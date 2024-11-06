variable "ec2-instances" {
    type = map(object({
        ami = string
        instance_type = string
        tags = map(string)
        vpc_security_group_ids = list(string)
        associate_public_ip_address = bool
        zone = string
        subnet_id = string
        key_name = string
        bootstrap_scripts = object({
            git_repo = string
            folder_path = string
            script_name = string
      })
    }))  
}

variable "dir_path_to_login_keys" {
    type = string
    default = "/Users/ansh.lehri/desktop/login-keys"
}

variable "aws_access_key_id" {
    type = string
}

variable "aws_access_secret_key" {
    type = string
}

variable "github_pat" {
  type = string
}

variable "github_username" {
  type = string
}