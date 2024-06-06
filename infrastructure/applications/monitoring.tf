resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  namespace  = "monitoring"
  repository = "https://helm-charts.itboon.top/prometheus-community"
  chart      = "prometheus"
  version    = "25.21.0"

   values = [
    file("${path.module}/prometheus-values.yaml")
  ]

  depends_on = [ kubernetes_namespace.monitoring ]
}


resource "helm_release" "prometheus-adapter" {
  name       = "prometheus-adapter"
  namespace  = "monitoring"
  repository = "https://helm-charts.itboon.top/prometheus-community"
  chart      = "prometheus-adapter"
  version    = "4.10.0"

   values = [
    file("${path.module}/prometheus-adapter-values.yaml")
  ]

  depends_on = [ helm_release.prometheus ]
}

resource "helm_release" "grafana" {
  name       = "grafana"
  namespace  = "monitoring"
  repository = "https://helm-charts.itboon.top/grafana"
  chart      = "grafana"
  version    = "7.3.11"

   values = [
    file("${path.module}/grafana-values.yaml")
  ]
  depends_on = [ helm_release.prometheus ]
}

data "kubernetes_secret" "grafana_pass" {
  metadata {
    name = "grafana"
    namespace = "monitoring"
  }
  depends_on = [ helm_release.grafana ]
}

output "grafana_pass" {
  sensitive =  true
  value = data.kubernetes_secret.grafana_pass.data
}


# resource "kubernetes_config_map" "jmx_dashboard" {
#   metadata {
#     name = "jmx-dashboard"
#     namespace = "monitoring"
#   }

#   data = {
#     "jmx-dashboard.json" = file("${path.module}/grafana-dashboard/JMX.json")
#     "k6-dashboard.json" = file("${path.module}/grafana-dashboard/k6.json")
#     "logstash-dashboard.json" = file("${path.module}/grafana-dashboard/logstash.json")
#     "opencost-dashboard.json" = file("${path.module}/grafana-dashboard/opencost.json")
#   }
# }
