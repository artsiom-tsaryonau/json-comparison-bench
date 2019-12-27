# build stage
FROM gradle:jdk11
ARG ARTIFACT_PATH=json-comparison-application/build/libs
ARG ARTIFACT_OLD=json-comparison-application-0.0.1-SNAPSHOT.jar
ARG ARTIFACT_NEW=app.jar
RUN apt-get install git && git clone https://github.com/artsiom-tsaryonau/json-comparison.git
WORKDIR json-comparison
RUN chmod +x gradlew && \
    ./gradlew clean build -x pmdMain -x spotbugsMain -x checkstyleMain --no-daemon && \
    cd ${ARTIFACT_PATH} && mv ${ARTIFACT_OLD} ${ARTIFACT_NEW}

# performance test stage
FROM ubuntu:18.04
# adoptopenjdk/11 without CMD entry point
ARG ESUM='6dd0c9c8a740e6c19149e98034fba8e368fd9aa16ab417aa636854d40db1a161'
ARG BINARY_URL='https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.5%2B10/OpenJDK11U-jdk_x64_linux_hotspot_11.0.5_10.tar.gz'
ARG DEBIAN_FRONTEND=noninteractive
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'
ENV JAVA_VERSION jdk-11.0.5+10
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl ca-certificates fontconfig locales \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*
RUN set -eux; \
    curl -LfsSo /tmp/openjdk.tar.gz ${BINARY_URL}; \
    echo "${ESUM} */tmp/openjdk.tar.gz" | sha256sum -c -; \
    mkdir -p /opt/java/openjdk; \
    cd /opt/java/openjdk; \
    tar -xf /tmp/openjdk.tar.gz --strip-components=1; \
    rm -rf /tmp/openjdk.tar.gz;
ENV JAVA_HOME=/opt/java/openjdk \
    PATH="/opt/java/openjdk/bin:$PATH"
# custom part of the stage
RUN apt-get update && apt-get install -y python default-jre-headless python-tk python-pip python-dev \
                       libxml2-dev libxslt-dev zlib1g-dev net-tools && \
    pip install bzt

WORKDIR /home/tmp
CMD ["bzt", "quick_test.yml"]
