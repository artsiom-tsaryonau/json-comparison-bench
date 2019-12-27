FROM gradle:jdk11 AS build_project

ARG ARTIFACT_PATH=json-comparison-application/build/libs
ARG ARTIFACT_OLD=json-comparison-application-0.0.1-SNAPSHOT.jar
ARG ARTIFACT_NEW=app.jar

RUN apt-get install git && git clone https://github.com/artsiom-tsaryonau/json-comparison.git

WORKDIR json-comparison
RUN chmod +x gradlew && \
    ./gradlew clean build -x pmdMain -x spotbugsMain -x checkstyleMain --no-daemon && \
    cd ${ARTIFACT_PATH} && mv ${ARTIFACT_OLD} ${ARTIFACT_NEW}
