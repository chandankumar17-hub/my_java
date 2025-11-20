# Stage 1: Build Maven project
FROM maven:3.9.2-eclipse-temurin-17 AS build
WORKDIR /app

# Copy source code
COPY pom.xml .
COPY src ./src

RUN mvn clean package

# Stage 2: Create runtime image
FROM openjdk:17-jdk-slim
WORKDIR /app

COPY --from=build /app/target/*.jar app.jar

ENTRYPOINT ["java", "-jar", "app.jar"]
