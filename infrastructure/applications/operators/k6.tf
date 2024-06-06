
# https://github.com/grafana/k6-operator/tree/main/charts/k6-operator
resource "helm_release" "k6-operator" {
  name       = "k6-operator"
#   namespace  = "k6"
#   create_namespace = true
  repository = "https://helm-charts.itboon.top/grafana"
  chart      = "k6-operator"
  version    = "3.6.0"

  set {
    name = "authProxy.enabled"
    value = "false"
  }

  set {
    name = "global.image.registry"
    value = "registry.cn-shenzhen.aliyuncs.com"
  }
  set {
    name = "manager.image.repository"
    value = "xiaoxitou/k6-operator"
  }
  set {
    name = "manager.image.tag"
    value = "controller-v0.0.14"
  }
}
