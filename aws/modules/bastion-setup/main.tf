resource "aws_security_group_rule" "whitelist-bastion-80" {
    type              = "ingress"
    from_port         = 80
    to_port           = 80
    protocol          = "tcp"
    cidr_blocks       = ["${var.bastion_cluster_connect.bastion_pvt_ip}/32"]
    security_group_id = var.bastion_cluster_connect.security_group_id
  
}

resource "aws_security_group_rule" "whitelist-bastion-443" {
    type              = "ingress"
    from_port         = 443
    to_port           = 443
    protocol          = "tcp"
    cidr_blocks       = ["${var.bastion_cluster_connect.bastion_pvt_ip}/32"]
    security_group_id = var.bastion_cluster_connect.security_group_id
}


resource "null_resource" "bastion-cluster-connect" {
    connection {
        type     = "ssh"
        user     = var.bastion_cluster_connect.user
        private_key = file("${var.bastion_cluster_connect.login-key-path}/${var.bastion_cluster_connect.login-key-name}.pem")
        host     = var.bastion_cluster_connect.host
    }

    for_each = var.bastion_cluster_connect.clusters

    provisioner "remote-exec" {
        inline = [
            "aws eks update-kubeconfig --region ${each.value} --name ${each.key}",
            "kubectl config current-context",
            "kubectl get nodes"
        ]
    }
}