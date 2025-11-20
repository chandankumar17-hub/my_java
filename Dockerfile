# Stage 1: Build Maven project
FROM maven:3.9.2-eclipse-temurin-17 AS build
WORKDIR /app

# Copy only the POM (no src/ since it doesn't exist)
COPY pom.xml .

# Run Maven package (will produce an empty JAR if no src/)
RUN mvn clean package

# Stage 2: Runtime image
FROM openjdk:17-jdk-slim
WORKDIR /app

# Copy the JAR from the build stage
COPY --from=build /app/target/*.jar app.jar

# Run the app
ENTRYPOINT ["java", "-jar", "app.jar"]
