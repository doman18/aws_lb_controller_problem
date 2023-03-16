resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }

  depends_on = [
    aws_eks_node_group.private_nodes
  ]
}

########################################  Prometheus (helm)   ###################################### 

resource "helm_release" "prometheus" {
  chart      = "prometheus"
  name       = "prometheus"
  namespace  = kubernetes_namespace.monitoring.id
  repository = "https://prometheus-community.github.io/helm-charts"
  version    = "19.3.3"

  values = [
    "${file("6.prometheus-values.yaml")}" 
  ]

  depends_on = [
    helm_release.aws_load_balancer_controller,
    aws_eks_addon.ebs_csi_driver
  ]
}

########################################  loki (helm)   ###################################### 
# https://artifacthub.io/packages/helm/grafana/loki-stack

resource "helm_release" "loki" {
  chart      = "loki-stack"
  name       = "loki"
  namespace  = kubernetes_namespace.monitoring.id
  repository = "https://grafana.github.io/helm-charts"
  version    = "2.9.9"

  depends_on = [
    helm_release.aws_load_balancer_controller
  ]
}

########################################  Grafana (helm)   ######################################
resource "helm_release" "grafana" {
  chart      = "grafana"
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  namespace  = kubernetes_namespace.monitoring.id
  version    = "6.50.7"

  values = [
    "${file("6.grafana-values.yaml")}"
  ]

  depends_on = [
    aws_eks_addon.ebs_csi_driver
  ]
}

# because of "Failed to create Ingress 'monitoring/grafana' because: Unauthorized" error (probably service account is not ready yet)
resource "time_sleep" "wait_grafana" {
  create_duration = "30s"

  depends_on = [
    helm_release.grafana
  ]
}

# since helm chart ingress gives problems we have to create it by our own
resource "kubernetes_ingress_v1" "grafana_ingress" {
  metadata {
    name = "grafana"
    namespace = "monitoring"
    annotations = {
        "alb.ingress.kubernetes.io/load-balancer-name" = "grafana-ingress"
        "alb.ingress.kubernetes.io/target-type" = "ip"
        "alb.ingress.kubernetes.io/healthcheck-path" = "/login"
    }
  }

  spec {
    ingress_class_name = "alb"
    rule {
      host = "grafana.djangoapp.lan"
      http {
        path {
          backend {
            service {
              name = "grafana"
              port {
                number = 80
              }
            }
          }

          path = "/*"
        }
      }
    }
  }

  depends_on = [
    kubernetes_namespace.monitoring,
    time_sleep.wait_grafana,
    helm_release.aws_load_balancer_controller
  ]
}
