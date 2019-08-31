FROM openjdk:8

ARG hbase_version=2.1.5

LABEL maintainer="Lee Dongjin <dongjin@apache.org>"

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/

ENV HBASE_VERSION $hbase_version
ENV HBASE_HOME /opt/hbase
ENV HBASE_URL http://www.apache.org/dist/hbase/$HBASE_VERSION/hbase-$HBASE_VERSION-bin.tar.gz
ENV HBASE_MANAGES_ZK false

ENV PATH ${PATH}:${HBASE_HOME}/bin

ENV USER root

COPY start-hbase.sh /tmp/

RUN set -x \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    openjdk-8-jdk net-tools curl netcat gnupg \
 && rm -rf /var/lib/apt/lists/* \
 && curl -O http://www.apache.org/dist/hbase/KEYS \
 && gpg --import KEYS \
 && curl -fSL "$HBASE_URL" -o /tmp/hbase.tar.gz \
 && curl -fSL "$HBASE_URL.asc" -o /tmp/hbase.tar.gz.asc \
 && gpg --verify /tmp/hbase.tar.gz.asc \
 && tar -xvf /tmp/hbase.tar.gz -C /opt/ \
 && rm /tmp/hbase.tar.gz* \
 && ln -s /opt/hbase-$HBASE_VERSION $HBASE_HOME \
 && mv /tmp/start-hbase.sh /usr/bin \
 && chmod a+x /usr/bin/start-hbase.sh

# Use "exec" form so that it runs as PID 1 (useful for graceful shutdown)
CMD ["start-hbase.sh"]

