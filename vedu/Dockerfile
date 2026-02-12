# Stage 1: Build
# Stage 1: Build
# Using a specific Maven image with Temurin JDK 17
FROM maven:3.9.5-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Run
# Replacing the deprecated openjdk:17-jdk-slim
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
# This matches your <finalName>vedu</finalName> from the pom.xml
COPY --from=build /app/target/vedu.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]