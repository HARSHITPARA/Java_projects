# --- Stage 1: Build Stage ---
# Use Maven to compile and package the JAR
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

# Copy only the pom.xml first to cache dependencies (improves build speed)
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy the source code and build the application
COPY src ./src
RUN mvn clean package -DskipTests

# --- Stage 2: Runtime Stage ---
# Use a lightweight JRE (Java Runtime Environment) for the final image
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Copy the JAR from the build stage
# Note: 'vedu-app.jar' is a generic name; ensure it matches your pom.xml artifactId
COPY --from=build /app/target/Vedu.jar app.jar

# Expose the port your Spring app runs on (usually 8080)
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]