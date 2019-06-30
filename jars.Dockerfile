FROM maven:3.6.1-jdk-8-slim@sha256:608e3a23cbeb210b5537e4bf51a1c31fe99887b83b49f3a68eb3e9fcd2eb3418 as build

WORKDIR /quarkus

COPY . .

# The streams client has support for native RocksDB https://github.com/quarkusio/quarkus/pull/2794
RUN set -e; \
  cd extensions/kafka-streams/; \
  mvn install

RUN set -e; \
  cd extensions/kafka-client/; \
  mvn install

RUN sha256sum extensions/kafka-client/runtime/target/*.jar
RUN sha256sum extensions/kafka-client/deployment/target/*.jar

FROM scratch as export

COPY --from=build /quarkus/extensions/kafka-client/runtime/target/*.jar /
COPY --from=build /quarkus/extensions/kafka-client/deployment/target/*.jar /
