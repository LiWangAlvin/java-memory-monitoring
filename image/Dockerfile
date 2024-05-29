FROM ubuntu:22.04 as jar
WORKDIR /
RUN apt-get update -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y wget
RUN wget https://repo.maven.apache.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.20.0/jmx_prometheus_javaagent-0.20.0.jar

FROM docker.elastic.co/logstash/logstash:8.13.4
ADD prometheus-jmx-config.yaml /prometheus-jmx-config.yaml
COPY --from=jar /jmx_prometheus_javaagent-0.20.0.jar /jmx_prometheus_javaagent-0.20.0.jar


# sudo docker build . -t registry.cn-shenzhen.aliyuncs.com/xiaoxitou/logstash:8.13.4-jmx
# sudo docker push registry.cn-shenzhen.aliyuncs.com/xiaoxitou/logstash:8.13.4-jmx
