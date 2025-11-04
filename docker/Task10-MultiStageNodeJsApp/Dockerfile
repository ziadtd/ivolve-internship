# Stage 1
FROM maven:sapmachine AS builder
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# Stage 2
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
