ARG NEXUS_VERSION=3.70.1-java11-alpine

FROM maven:3-eclipse-temurin-8-alpine AS build
RUN apk add git && git clone https://github.com/sonatype-nexus-community/nexus-repository-composer.git && \
 git clone https://github.com/sonatype-nexus-community/nexus-repository-apk.git && \
 #git clone --branch issue19-update-nexus-to-3.40.1-01 https://github.com/beiriannydd/nexus-repository-cargo.git
  git clone https://github.com/sonatype-nexus-community/nexus-repository-cargo.git

RUN cd /nexus-repository-composer/; \
    mvn clean package -PbuildKar;
RUN cd /nexus-repository-apk/; \
    mvn clean package -PbuildKar;
RUN cd /nexus-repository-cargo/; \
    mvn clean package -PbuildKar;

FROM sonatype/nexus3:$NEXUS_VERSION

ARG DEPLOY_DIR=/opt/sonatype/nexus/deploy/
USER root
COPY --from=build /nexus-repository-composer/nexus-repository-composer/target/nexus-repository-composer-*-bundle.kar ${DEPLOY_DIR}
COPY --from=build /nexus-repository-apk/nexus-repository-apk/target/nexus-repository-apk-*-bundle.kar ${DEPLOY_DIR}
COPY --from=build /nexus-repository-cargo/target/nexus-repository-cargo-*-bundle.kar ${DEPLOY_DIR}
USER nexus
