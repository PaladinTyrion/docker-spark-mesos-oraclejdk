### Based on https://github.com/apache/spark/blob/master/docker/spark-mesos/Dockerfile
FROM mesosphere/mesos:1.0.2-rc1

RUN apt-get remove -y --auto-remove openjdk* && \
    rm -fr /var/cache/oracle-jdk* && \
    apt-get clean && apt-get autoremove -y

RUN apt-get update && apt-get install -y --no-install-recommends \
        bzip2 \
        unzip \
        xz-utils \
    && rm -rf /var/lib/apt/lists/*

RUN echo 'deb http://deb.debian.org/debian jessie-backports main' > /etc/apt/sources.list.d/jessie-backports.list

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

# add a simple script that can auto-detect the appropriate JAVA_HOME value
# based on whether the JDK or only the JRE is installed
RUN { \
        echo '#!/bin/sh'; \
        echo 'set -e'; \
        echo; \
        echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
    } > /usr/local/bin/docker-java-home \
    && chmod +x /usr/local/bin/docker-java-home

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

ENV JAVA_VERSION 8u111
ENV JAVA_DEBIAN_VERSION 8u111-b14-2~bpo8+1

# see https://bugs.debian.org/775775
# and https://github.com/docker-library/java/issues/19#issuecomment-70546872
ENV CA_CERTIFICATES_JAVA_VERSION 20140324

RUN set -x \
    && apt-get update \
    && apt-get install -y \
        openjdk-8-jdk="$JAVA_DEBIAN_VERSION" \
        ca-certificates-java="$CA_CERTIFICATES_JAVA_VERSION" \
    && rm -rf /var/lib/apt/lists/* \
    && [ "$JAVA_HOME" = "$(docker-java-home)" ]

# see CA_CERTIFICATES_JAVA_VERSION notes above
RUN /var/lib/dpkg/info/ca-certificates-java.postinst configure

# Update the base ubuntu image with dependencies needed for Spark
RUN apt-get install -y python libnss3 curl && \
    apt-get autoremove -y

RUN mkdir /opt/spark && \
    curl http://archive.apache.org/dist/spark/spark-2.0.1/spark-2.0.1-bin-hadoop2.7.tgz \
    | tar --strip-components=1 -xzC /opt/spark && \
    rm -rf /opt/spark/examples

ENV SPARK_HOME /opt/spark
ENV PATH $PATH:/opt/spark/bin
ENV MESOS_NATIVE_JAVA_LIBRARY /usr/local/lib/libmesos.so
ENV SPARK_EXECUTOR_URI http://archive.apache.org/dist/spark/spark-2.0.1/spark-2.0.1-bin-hadoop2.7.tgz

EXPOSE 4040, 8080
