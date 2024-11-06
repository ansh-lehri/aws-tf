output "eks_clusters" {
    value = {
        for eks_name, eks_config in var.eks_clusters : eks_name => {
            cluster_id = aws_eks_cluster.eks[eks_name].cluster_id
            id = aws_eks_cluster.eks[eks_name].id
            endpoint = aws_eks_cluster.eks[eks_name].endpoint
            status = aws_eks_cluster.eks[eks_name].status
            platform_version = aws_eks_cluster.eks[eks_name].platform_version
        }
    }
  
}