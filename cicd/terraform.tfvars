terraform_backend_config = {
    bucket_name = "rattle-cicd"
    path_to_tfstate_file = "aws/tfstate"
    bucket_region = "ap-south-1"
    encryption = false
}

cicd_server_config = {
    region = "ap-south-1"
    ip = ""
    login-key-name = ""
    dir_path_to_login_keys = ""
    user = ""
}



repos_to_build_and_deploy = [
    {
        code_git_repo = "flask-hello-world"
        dockerfile_path = "/"
        image = {
            registry = "docker.io"
            name = "<docker registry name. Ex: ansh2599lehri>/hello-world"  # include path inside registry + main name
            version = "v8"
        }
        team_name = "rattle-test"
    }
]