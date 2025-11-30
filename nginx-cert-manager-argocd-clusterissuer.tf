# Ingress (NGINX) and Cert-Manager via Helm
#
# - NGINX chart will create a LoadBalancer service (ELB) by default based on the
#   chart values (we supply a simple yaml file).
# - Cert-manager chart will be installed with CRDs if enabled.
#
# Keep chart versions updated as needed.


# NGINX Ingress
resource "helm_release" "nginx_ingress" {
  provider         = helm  # Helm provider references kubernetes.post_eks
  name             = "nginx-ingress-${var.environment}"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.14.0"
  timeout          = 600
  namespace        = "ingress-nginx"
  create_namespace = true

  values = [
    file("nginx-values.yaml")
  ]

  depends_on = [module.eks]  # ensure EKS cluster is ready
}

# Cert-Manager
resource "helm_release" "cert_manager" {
  provider         = helm  # Helm provider references kubernetes.post_eks
  name             = "cert-manager-${var.environment}"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "1.14.5"
  namespace        = "cert-manager"
  create_namespace = true

  values = [
    file("cert-manager-values.yaml")
  ]

  depends_on = [module.eks]  # ensure EKS cluster is ready
}


#Create kubeconfig inside Terraform
resource "local_file" "kubeconfig" {
  filename = "${path.module}/kubeconfig"

  depends_on = [
    module.eks
  ]

  content = <<EOF
apiVersion: v1
kind: Config
clusters:
- name: eks
  cluster:
    server: ${data.aws_eks_cluster.cluster.endpoint}
    certificate-authority-data: ${data.aws_eks_cluster.cluster.certificate_authority[0].data}
contexts:
- name: eks
  context:
    cluster: eks
    user: eks
current-context: eks
users:
- name: eks
  user:
    token: ${data.aws_eks_cluster_auth.cluster.token}
EOF
}

#apply ClusterIssuer using kubectl + kubeconfig
resource "null_resource" "create_cluster_issuer" {
  depends_on = [
    helm_release.cert_manager,
    local_file.kubeconfig
  ]

  provisioner "local-exec" {
    environment = {
      KUBECONFIG = local_file.kubeconfig.filename
    }

    command = <<EOT
kubectl apply -f cluster-issuer.yaml
EOT
  }
}



#ArgoCd
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.52.0"
  namespace  = "argocd"
  create_namespace = true

  values = [
    file("argocd-values.yaml")
  ]

  depends_on = [null_resource.create_cluster_issuer]
}
