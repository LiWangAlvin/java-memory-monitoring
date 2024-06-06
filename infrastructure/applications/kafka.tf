resource "kubernetes_config_map" "kafka-metrics" {
  metadata {
    name = "kafka-metrics"
    namespace = "kafka"
  }

  data = {
    "kafka-metrics-config.yml" = file("${path.module}/kafka-metrics.yml")
  }
}

resource "kubernetes_manifest" "kafka-cluster" {
  manifest = {
    apiVersion = "kafka.strimzi.io/v1beta2"
    kind = "Kafka"
    metadata = {
        name = "kafka"
        namespace = "kafka"
    }
    spec = {
        kafka = {
            version = "3.7.0"
            replicas = 3
            listeners =[ {
                name = "plain"
                port = 9092
                type = "internal"
                tls = "false"
            },
            {
                    name = "tls"
                    port = 9093
                    type = "internal"
                    tls = "true"
                }
            ]
            config = {
                "offsets.topic.replication.factor" = 3
                "transaction.state.log.replication.factor" = 3
                "transaction.state.log.min.isr" = 2
                "default.replication.factor" = 3
                "min.insync.replicas" = 2
                "inter.broker.protocol.version" = "3.7"
            }
            storage = { type = "ephemeral"  }
            resources = {
                requests = {memory = "4Gi", cpu="100m"}
                limits = {memory = "4Gi"}
            }
            jvmOptions = {
                "-Xmx" = "2867m"
                "-Xms" = "2867m"
            }
            template = {
                pod = {
                    metadata = {
                        annotations = {
                            "prometheus.io/scrape" = "true"
                            "prometheus.io/scheme"= "http"
                            "prometheus.io/path"= "/metrics"
                            "prometheus.io/port"= 9404
                        }
                        labels = { app = "kafka"}
                    }
                }
            }
            metricsConfig = {
                type =  "jmxPrometheusExporter"
                valueFrom = {
                    configMapKeyRef = {
                        name = "kafka-metrics"
                        key = "kafka-metrics-config.yml"
                    }
                }
            }

        }
        zookeeper = {
            replicas = 3
            storage = { type = "ephemeral"}
        }
    }
  }
  depends_on = [ kubernetes_config_map.kafka-metrics]
}
