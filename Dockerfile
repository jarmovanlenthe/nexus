ARG NEXUS_VERSION=latest

FROM maven:3-jdk-8-alpine AS build
RUN apk add git && git clone https://github.com/sonatype-nexus-community/nexus-repository-composer.git && git clone https://github.com/sonatype-nexus-community/nexus-repository-apk.git

RUN cd /nexus-repository-composer/; \
    mvn clean package -PbuildKar;
RUN cd /nexus-repository-apk/; \
    mvn clean package -PbuildKar;

FROM sonatype/nexus3:$NEXUS_VERSION

ARG DEPLOY_DIR=/opt/sonatype/nexus/deploy/
USER root
COPY --from=build /nexus-repository-composer/nexus-repository-composer/target/nexus-repository-composer-*-bundle.kar ${DEPLOY_DIR}
COPY --from=build /nexus-repository-apk/nexus-repository-apk/target/nexus-repository-apk-*-bundle.kar ${DEPLOY_DIR}
USER nexus
