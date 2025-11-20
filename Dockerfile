# Stage 1: Build Maven project
FROM maven:3.9.2-eclipse-temurin-17 AS build
WORKDIR /app

# Copy only pom.xml (no src/)
COPY pom.xml .

# Run Maven package
RUN mvn clean package

# Stage 2: Runtime image
FROM eclipse-temurin:17-jdk-focal
WORKDIR /app

# Copy JAR from build stage
COPY --from=build /app/target/*.jar app.jar

# Run the app
ENTRYPOINT ["java", "-jar", "app.jar"]
