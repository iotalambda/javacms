FROM eclipse-temurin:23 AS base

FROM base AS builder
WORKDIR /app
COPY . .
RUN chmod +x mvnw && \
    ./mvnw package -DskipTests

FROM base AS runner
WORKDIR /opt/app
COPY --from=builder app/target/app-1.0.0.jar ./app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]