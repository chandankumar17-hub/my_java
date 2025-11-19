FROM eclipse-temurin:17-jdk
WORKDIR /app
COPY target/my_java_app.jar .
EXPOSE 8080
CMD ["java", "-jar", "my_java_app.jar"]
