resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = "argocd"

    annotations = {
      name = local.namespace
    }

    labels = {
      namespace = local.namespace
    }
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = kubernetes_namespace_v1.argocd.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "6.7.18" # pin a known version; adjust as you like

  # Minimal, safe defaults
  values = [
    yamlencode({
      configs = {
        params = {
          # keep server behind service; UI access via port-forward unless you add ingress
          "server.insecure" = "false"
        }
      }
      server = {
        service = {
          type = "ClusterIP"
        }
      }
    })
  ]
}

output "argocd_ui_port_forward" {
  value = "kubectl -n argocd port-forward svc/argocd-server 8080:443"
}

output "argocd_initial_admin_secret_cmd" {
  value = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo"
}