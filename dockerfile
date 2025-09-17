# Stage 1: Build ứng dụng (dùng Maven)
FROM maven:3.8.5-openjdk-17 AS build
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# Stage 2: Chạy ứng dụng
FROM openjdk:17-jdk-slim
WORKDIR /app
COPY --from=build /app/target/*backend-0.0.1-SNAPSHOT app.jar  # Thay *.jar bằng tên JAR cụ thể nếu cần, ví dụ: smartdine-0.0.1-SNAPSHOT.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
