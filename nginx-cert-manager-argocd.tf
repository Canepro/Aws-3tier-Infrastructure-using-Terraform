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


#ClusterIssuer
resource "kubernetes_manifest" "cluster_issuer" {
  depends_on = [helm_release.cert_manager]

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "http-01-production"
    }
    spec = {
      acme = {
        server = "https://acme-v02.api.letsencrypt.org/directory"
        email  = var.letsencrypt_email
        privateKeySecretRef = {
          name = "acme-private-key"
        }
        solvers = [
          {
            http01 = {
              ingress = {
                class = "nginx"
              }
            }
          }
        ]
      }
    }
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

  depends_on = [kubernetes_manifest.cluster_issuer]
}
