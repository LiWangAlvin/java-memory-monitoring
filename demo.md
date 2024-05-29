# Prepare Environment

## 创建Kubernetes

使用Terraform在ACK上快速创建一套测试用的Kubernetes，机器用spot类型以节省资源

```shell
# 设置默认storageclass
kubectl patch storageclass alicloud-disk-ssd -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

## 安装metrics-server

```shell
# 要安装metrics-server
# https://kubernetes.io/docs/tasks/debug/debug-cluster/resource-metrics-pipeline/#metrics-server
# https://github.com/kubernetes-sigs/metrics-server/releases
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.7.1/components.yaml

kubectl set image deployment/metrics-server metrics-server=bitnami/metrics-server:0.7.1 --namespace kube-system

# 这一行要改
# - --insecureSkipTLSVerify=true
```



## 安装Prometheus stack

使用prometheus operator来管理prometheus及其它资源

### 安装promethus

```shell
# 国内源
helm repo add prometheus-community "https://helm-charts.itboon.top/prometheus-community"

# 查看和修改配置，把persistent磁盘大小改成20G(低于20G不支持、、、)
# 配置告警，recording rules等
# helm show values prometheus-community/prometheus > prometheus-values.yaml

helm upgrade --install prometheus prometheus-community/prometheus -f prometheus-values.yaml

# 替换kube-state 为其它镜像 https://gitee.com/mirrors/kube-state-metrics#container-image

kubectl set image deployment/prometheus-kube-state-metrics kube-state-metrics=bitnami/kube-state-metrics:2.12.0

# 安装adapter
# 查看和修改配置，prometheus地址和image地址
# helm show values prometheus-community/prometheus-adapter > prometheus-adapter-values.yaml
 
helm upgrade --install prometheus-adapter prometheus-community/prometheus-adapter -f prometheus-adapter-values.yaml

# 检查指标是否OK
kubectl get --raw /apis/custom.metrics.k8s.io/v1beta1/namespaces/default/pods/*/jvm_memory_bytes_heap_used | jq


```

### 安装grafana

```shell
# 安装grafana
helm repo add grafana "https://helm-charts.itboon.top/grafana"

# 修改grafana添加prometheus的 datasources
# helm show values grafana/grafana > grafana-values.yaml

helm upgrade --install grafana grafana/grafana -f grafana-values.yaml

# 获取grafana密码
pass=$(kubectl get secret grafana -o json | jq .data.\"admin-password\" -r | base64 -d)
echo $pass

http://39.108.173.27

```

## 安装Kafka

### 安装strimiz operator

```shell
helm upgrade --install strimzi-cluster-operator oci://quay.io/strimzi-helm/strimzi-kafka-operator
```

### 安装kafka和zookeeper集群

```shell
kubectl apply -f kafka-with-metrics.yaml
```

测试一下kafka功能

```shell
bin/kafka-console-producer.sh --bootstrap-server 10.10.0.21:9092 --topic test
bin/kafka-console-consumer.sh --bootstrap-server 10.10.0.21:9092 --topic test --from-beginning
```



## 安装Logstash

### 生成自定义的image 以包含jmx-exporter

```dockerfile
FROM ubuntu:22.04 as jar
WORKDIR /
RUN apt-get update -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y wget
RUN wget https://repo.maven.apache.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.20.0/jmx_prometheus_javaagent-0.20.0.jar

FROM docker.elastic.co/logstash/logstash:8.13.4
ADD prometheus-jmx-config.yaml /prometheus-jmx-config.yaml
COPY --from=jar /jmx_prometheus_javaagent-0.20.0.jar /jmx_prometheus_javaagent-0.20.0.jar
```

### 启动logstash

[Kafka output plugin | Logstash Reference [8.13\] | Elastic](https://www.elastic.co/guide/en/logstash/current/plugins-outputs-kafka.html)

```shell
kubectl apply -f logstash.yaml

# 测试logstash --> kafka
# 在kafka pod
bin/kafka-console-consumer.sh --bootstrap-server 10.10.0.21:9092 --topic test
# 朝logstash发送信息，kafka能正常收到
curl -XPOST http://120.25.202.23:8080/ -d 'Hello Kakfa'
```

# 配置Dashboard和告警

## 登录grafana并导入jmx dashboard

## 配置告警

```yaml

```

# 测试

## 对logstash进行压力测试



### 结果

# Conclusion

[Exporters and integrations | Prometheus](https://prometheus.io/docs/instrumenting/exporters/)

[Getting Started with Java Management Extensions (JMX): Developing Management and Monitoring Solutions (oracle.com)](https://www.oracle.com/technical-resources/articles/javase/jmx.html)

# KubeCost

[Kubecost | Kubernetes cost monitoring and management](https://www.kubecost.com/)

[The Guide To Kubernetes HPA by Example (kubecost.com)](https://www.kubecost.com/kubernetes-autoscaling/kubernetes-hpa/)

[First Time User Guide | 2.2 (latest) | Kubecost Docs](https://docs.kubecost.com/install-and-configure/install/first-time-user-guide)





