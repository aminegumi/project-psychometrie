# Multi-stage build for Spring Boot backend

FROM maven:3.9.9-eclipse-temurin-17 AS build
WORKDIR /workspace

# Cache deps
COPY pom.xml ./
RUN mvn -q -DskipTests dependency:go-offline

# Build
COPY src ./src
RUN mvn -q -DskipTests clean package

# Slim runtime
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app

# Non-root user
RUN useradd -r -u 10001 appuser && \
    mkdir -p /app /data/uploads && chown -R appuser:appuser /app /data/uploads
USER appuser

COPY --from=build /workspace/target/*.jar app.jar

EXPOSE 8085
ENV JAVA_OPTS=""
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
