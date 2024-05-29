
# https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update



# 国内源
helm repo add prometheus-community "https://helm-charts.itboon.top/prometheus-community"


helm show values prometheus-community/prometheus > prometheus-values.yaml

helm upgrade --install prometheus prometheus-community/prometheus --create-namespace -f prometheus-values.yaml


# 安装grafana
helm repo add grafana "https://helm-charts.itboon.top/grafana"

helm show values grafana/grafana > grafana-values.yaml

# enable prometheus datasource

helm upgrade --install grafana grafana/grafana -n monitoring --create-namespace -f grafana-values.yaml

kubectl get secret grafana -o json | jq .data.\"admin-password\" -r | base64 -d

# Kafka
# install strimzi
helm install strimzi-cluster-operator oci://quay.io/strimzi-helm/strimzi-kafka-operator
helm ls

# 设置默认stroageclass
kubectl patch storageclass alicloud-disk-ssd -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'