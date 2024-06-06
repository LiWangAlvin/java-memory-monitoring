resource "kubernetes_namespace" "logstash" {
  metadata {
    name = "logstash"
  }
}

resource "kubernetes_config_map" "logstash" {
  metadata {
    name = "pipelines"
    namespace = kubernetes_namespace.logstash.metadata[0].name
  }

  data = {
    "pipelines.yml" = file("${path.module}/pipelines.yml")
  }
}

resource "kubernetes_deployment" "logstash" {
  metadata {
    name = "logstash"
    namespace = kubernetes_namespace.logstash.metadata[0].name
    labels = {
      app =  "logstash"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app =  "logstash"
      }
    }

    template {
      metadata {
        labels = {
          app =  "logstash"
        }
        annotations = {
          "prometheus.io/scrape" = "true"
          "prometheus.io/scheme"=  "http"
          "prometheus.io/path" = "/metrics"
        }
      }

      spec {
        container {
          image = "registry.cn-shenzhen.aliyuncs.com/xiaoxitou/logstash:8.13.4-jmx"
          name  = "logstash"

          env {
            name = "LS_JAVA_OPTS"
            value = "-Xms1g -Xmx1g -javaagent:/jmx_prometheus_javaagent-0.20.0.jar=8088:/prometheus-jmx-config.yaml"
          }

          resources {
            limits = {
              memory = "2Gi"
            }
            requests = {
              cpu    = "100m"
              memory = "2Gi"
            }
          }
          port  {
            name = "jmx-metrics"
            container_port = 8088
          }

          volume_mount {
              mount_path = "/usr/share/logstash/config/pipelines.yml"
            name       = "pipelines"
            sub_path = "pipelines.yml"

          }
        }
        container {
          image = "registry.cn-shenzhen.aliyuncs.com/xiaoxitou/logstash-exporter:v1.6.4"
          name  = "logstash-exporter"
          resources {
            limits = {
              memory = "256Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
          }
          port  {
            name = "metrics"
            container_port = 9198
          }
        }
        volume {
          name = "pipelines"
            config_map {
              name = kubernetes_config_map.logstash.metadata[0].name
            }
        }
      }
    }
  }
  depends_on = [ kubernetes_config_map.logstash ]
}

resource "kubernetes_service" "logstash" {
  metadata {
    name = "logstash"
    namespace = kubernetes_namespace.logstash.metadata[0].name
  }

  spec {
    selector = {
      app = "logstash"
    }

    port {
      name = "http"
      port        = 8080
      target_port = 8080
    }
    port {
      name = "json-metircs"
      port        = 9600
      target_port = 9600
    }

    port {
      name = "jmx-metrics"
      port        = 8088
      target_port = 8088
    }


    type = "ClusterIP"
  }
}

# resource "kubernetes_deployment" "logstash-idle" {
#   metadata {
#     name = "logstash-idle"
#     namespace = kubernetes_namespace.logstash.metadata[0].name
#     labels = {
#       app =  "logstash-idle"
#     }
#   }

#   spec {
#     replicas = 1

#     selector {
#       match_labels = {
#         app = "logstash-idle"
#       }
#     }

#     template {
#       metadata {
#         labels = {
#           app = "logstash-idle"
#         }
#         annotations = {
#           "prometheus.io/scrape" = "true"
#           "prometheus.io/scheme"=  "http"
#           "prometheus.io/path" = "/metrics"
#         }
#       }

#       spec {
#         container {
#           image = "registry.cn-shenzhen.aliyuncs.com/xiaoxitou/logstash:8.13.4-jmx"
#           name  = "logstash"

#           env {
#             name = "LS_JAVA_OPTS"
#             value = "-Xms1g -Xmx1g -javaagent:/jmx_prometheus_javaagent-0.20.0.jar=8088:/prometheus-jmx-config.yaml"
#           }

#           resources {
#             limits = {
#               memory = "2Gi"
#             }
#             requests = {
#               cpu    = "100m"
#               memory = "2Gi"
#             }
#           }
#           port  {
#             name = "jmx-metrics"
#             container_port = 8088
#           }

#           volume_mount {
#               mount_path = "/usr/share/logstash/config/pipelines.yml"
#             name       = "pipelines"
#             sub_path = "pipelines.yml"

#           }
#         }
#         volume {
#           name = "pipelines"
#             config_map {
#               name = kubernetes_config_map.logstash.metadata[0].name
#             }
#         }
#       }
#     }
#   }
#   depends_on = [ kubernetes_config_map.logstash ]
# }