
FROM maven:3.8.5-openjdk-17 AS build
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

FROM openjdk:17-jdk-slim
WORKDIR /app
COPY --from=build /app/target/*backend-0.0.1-SNAPSHOT app.jar  
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
