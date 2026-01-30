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

resource "kubernetes_manifest" "argo_app_project" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "AppProject"
    metadata = {
      name      = local.namespace         # e.g. "mate-dev-weu-001"
      namespace = "argocd"
    }
    spec = {
      description = "Project for ${local.namespace}"

      sourceRepos = [
        "https://github.com/microtema/argo-cd.git"
      ]

      destinations = [
        {
          # MUST match your real target namespaces:
          # mate-customer-dev-weu-001, mate-order-dev-weu-001, ...
          namespace = "mate-*"
          server    = "https://kubernetes.default.svc"
        }
      ]

      clusterResourceWhitelist = [
        {
          group = "*"
          kind  = "*"
        }
      ]
    }
  }

  depends_on = [helm_release.argocd]
}

resource "kubernetes_manifest" "argo_root_app" {
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
        namespace = "argocd"
      }

      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
      }
    }
  }

  depends_on = [
    helm_release.argocd,
    kubernetes_manifest.argo_app_project
  ]
}
