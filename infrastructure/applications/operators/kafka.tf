resource "kubernetes_namespace" "kafka" {
  metadata {
    name = "kafka"
  }
}

resource "helm_release" "kafka-operator" {
  name       = "kafka-operator"
  namespace  = "kafka"
  repository = "oci://quay.io/strimzi-helm"
  chart      = "strimzi-kafka-operator"
  version    = "0.41.0"

  depends_on = [ kubernetes_namespace.kafka ]
}
