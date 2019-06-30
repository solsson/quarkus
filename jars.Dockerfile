FROM maven:3.6.1-jdk-8-slim@sha256:608e3a23cbeb210b5537e4bf51a1c31fe99887b83b49f3a68eb3e9fcd2eb3418 as build

WORKDIR /quarkus

# Build the release that the experimental branch is based on, to warm up the maven cache
RUN set -e; \
  curl -o quarkus.tgz -sLS https://github.com/quarkusio/quarkus/archive/0.18.0.tar.gz; \
  tar xvzf quarkus.tgz --strip-components=1 -C /quarkus; \
  rm quarkus.tgz

# The streams client has support for native RocksDB https://github.com/quarkusio/quarkus/pull/2794
RUN set -e; \
  cd extensions/kafka-streams/; \
  mvn install

COPY extensions/kafka-client/runtime/src extensions/kafka-client/runtime/src
COPY extensions/kafka-client/deployment/src extensions/kafka-client/deployment/src

RUN set -e; \
  cd extensions/kafka-client/; \
  mvn install

RUN ls -laR \
  /root/.m2/repository/org/xerial/snappy \
  /root/.m2/repository/org/lz4/lz4-java \
  /root/.m2/repository/com/github/luben/zstd-jni \
  /root/.m2/repository/io/quarkus/quarkus-kafka-*

FROM scratch as export

COPY --from=build /root/.m2/repository/io/quarkus/quarkus-kafka-* /
