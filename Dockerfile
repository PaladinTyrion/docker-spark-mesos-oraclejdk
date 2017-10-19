### Based on https://github.com/apache/spark/blob/master/docker/spark-mesos/Dockerfile
FROM mesosphere/mesos:1.0.2-rc1

# Install Oracle JDK instead of OpenJDK
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee /etc/apt/sources.list.d/webupd8team-java.list && \
    echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list && \
    apt-get remove -y --auto-remove openjdk* && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886 && \
    apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:webupd8team/java && \
    apt-get update && \
    echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
    echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections && \
    DEBIAN_FRONTEND=noninteractive  apt-get install -y oracle-java8-installer oracle-java8-set-default && \
    update-alternatives --remove java /usr/lib/jvm/java-9-openjdk-amd64/bin/java && \
    rm -rf /var/cache/oracle-jdk8-installer && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

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
