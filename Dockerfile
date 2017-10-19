FROM mesosphere/mesos:1.0.2-rc1

# Install Oracle JDK instead of OpenJDK
RUN apt-get remove -y --auto-remove openjdk* && \
    apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:webupd8team/java && \
    apt-get update && \
    echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections && \
    echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections && \
    sudo apt-get install -y oracle-java8-installer oracle-java8-set-default && \
    rm -r /var/cache/oracle-jdk* && \
    apt-get clean && apt-get autoremove -y

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
