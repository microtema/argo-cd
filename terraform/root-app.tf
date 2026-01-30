resource "kubernetes_namespace" "root_apps" {
  metadata {
    name = local.namespace

    annotations = {
      name = local.namespace
    }

    labels = {
      namespace = local.namespace
    }
  }
}

resource "kubernetes_manifest" "argo_apps" {

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = local.namespace
      namespace = "argocd"
    }
    spec = {
      project = "default"

      source = {
        repoURL        = "https://github.com/microtema/argo-cd.git"
        targetRevision = "main"
        path           = "argocd/apps"
      }

      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = local.namespace
      }

      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = ["CreateNamespace=false"]
      }
    }
  }

  depends_on = [helm_release.argocd, kubernetes_namespace.root_apps]
}
