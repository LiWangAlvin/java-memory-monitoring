# 测试jvm内存专用app

该程序接受http请求，每次请求会生成一个大小固定的java对象（默认值是 1k)， 可以通过启动第一个参数改变这个值。

通过量化的java程序，对jvm内存做深入的探索。

## 本地运行

```shell
mvn clean package

# 每次请求生成 2k 大小的对象
java -jar target/UniversityHttpServer-1.0-SNAPSHOT.jar 2048

# 访问
curl localhost:8080/university
# 返回
Created a new university: Example University, Data array size: 2048 integers

```

## build image

```shell
sudo docker build . -t jvm-demo-app:v1.0.0
```

## K8s 内运行

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: demo-app
  template:
    metadata:
      labels:
        app: demo-app
      annotations:
        prometheus.io/scrape: 'true'
        prometheus.io/scheme: 'http'
        prometheus.io/path: '/metrics'
        prometheus.io/port: '8088'
    spec:
      containers:
      - name: demo-app
        image: registry.cn-shenzhen.aliyuncs.com/xiaoxitou/jvm-demo-app:v1.0.1
        imagePullPolicy: IfNotPresent
        resources:
          requests:
            memory: 300Mi
            cpu: 100m
          limits:
            memory: 300Mi
        ports:
        - name: http
          containerPort: 8080
        - name: jmx-metrics
          containerPort: 8088
        env:
        - name: JAVA_OPTS
          value: "-Xms256m -Xmx256m"
        - name: OBJECT_SIZE
          value: "102400"
---
apiVersion: v1
kind: Service
metadata:
  name: demo-app
  labels:
    app: demo-app
spec:
  type: LoadBalancer
  ports:
  - port: 8080
    protocol: TCP
    name: http
  - port: 8088
    protocol: TCP
    name: jmx-metrics
  selector:
    app: demo-app
```

