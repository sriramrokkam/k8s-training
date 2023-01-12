# compile stage with name "builder"
FROM maven:sapmachine as builder
COPY . /usr/src/build
WORKDIR /usr/src/build
RUN mvn verify

# run stage
FROM sapmachine:lts as app
COPY --from=builder /usr/src/build/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/app.jar"]
