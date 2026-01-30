resource "kubernetes_namespace" "apps" {
  metadata {
    name = "apps"

    annotations = {
      name = local.namespace
    }

    labels = {
      namespace = local.namespace
    }
  }
}

# Needs Kubernetes provider that supports "kubernetes_manifest" (hashicorp/kubernetes >= 2.25.0)
resource "kubernetes_manifest" "argo_app_podinfo" {
  depends_on = [helm_release.argocd, kubernetes_namespace.apps]

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "podinfo"
      namespace = "argocd"
    }
    spec = {
      project = "default"

      source = {
        repoURL        = "https://stefanprodan.github.io/podinfo"
        chart          = "podinfo"
        targetRevision = "6.6.0"
        helm = {
          releaseName = "podinfo"
          values      = <<-EOT
            replicaCount: 2
            service:
              type: ClusterIP
          EOT
        }
      }

      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "apps"
      }

      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = ["CreateNamespace=true"]
      }
    }
  }
}