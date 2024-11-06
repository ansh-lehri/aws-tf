variable "bastion_cluster_connect" {

    type = object({
      host = string
      user = string
      bastion_pvt_ip = string
      security_group_id = string
      login-key-name = string
      login-key-path = string
      clusters = map(string)
    })
  
}