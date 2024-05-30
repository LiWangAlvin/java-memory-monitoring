FROM maven:3.6.3-jdk-8 as builder
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

FROM openjdk:8-jre-alpine

WORKDIR /app
COPY --from=builder /app/target/UniversityHttpServer-1.0-SNAPSHOT.jar /app/UniversityHttpServer.jar
COPY jmx_prometheus_javaagent-0.20.0.jar /jmx_prometheus_javaagent-0.20.0.jar
COPY prometheus-jmx-config.yaml /prometheus-jmx-config.yaml
COPY start.sh /app/start.sh
EXPOSE 8080
CMD ["/app/start.sh"]

