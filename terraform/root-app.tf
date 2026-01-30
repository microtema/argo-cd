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
      name      = local.namespace
      namespace = "argocd"
    }

    spec = {
      description = "Project for [${local.namespace}]"

      sourceRepos = ["https://github.com/microtema/argo-cd.git"]

      destinations = [{
        namespace = "${var.project}-*"
        server    = "https://kubernetes.default.svc"
      }]

      clusterResourceWhitelist = [{
        group : "*"
        kind : "*"
      }]
    }
  }

  depends_on = [helm_release.argocd, kubernetes_namespace.root_apps]
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
      project = local.namespace

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
      }
    }
  }

  depends_on = [helm_release.argocd, kubernetes_namespace.root_apps]
}
