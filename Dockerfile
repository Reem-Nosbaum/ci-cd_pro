# Use an old version of OpenJDK with known vulnerabilities
FROM openjdk:8u111-jdk-alpine as build

# Install Maven 3.9.2
ENV MAVEN_VERSION=3.9.2
RUN apk add --no-cache wget && \
    wget https://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz && \
    tar xzvf apache-maven-$MAVEN_VERSION-bin.tar.gz -C /opt && \
    ln -s /opt/apache-maven-$MAVEN_VERSION/bin/mvn /usr/bin/mvn

# Set the working directory
WORKDIR /app

# Copy the pom.xml and source code
COPY pom.xml .
COPY src ./src

# Build the application
RUN mvn clean package

# Use the same vulnerable version of OpenJDK to run the application
FROM openjdk:8u111-jdk-alpine

# Set the working directory
WORKDIR /app

# Copy the built jar from the build stage
COPY --from=build /app/target/*.jar app.jar

# Run the application
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
