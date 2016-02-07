# docker-spark-mesos-oraclejdk

A base Docker image for running Spark on Mesos, which can be referenced by the Spark property 'spark.mesos.executor.docker.image'.

Based on https://github.com/apache/spark/blob/master/docker/spark-mesos/Dockerfile

See http://spark.apache.org/docs/latest/running-on-mesos.html#mesos-docker-support



## Notes

Tagging format: "$mesosVersion-$sparkVersion"

Current Versions:

* Apache Spark: 1.6.1
* Apache Mesos: 0.22.1-1.1-ubuntu1404
* Oracle JDK: 7

Your versions of Mesos and Spark doesn't match? Submit a pull request and we'll trigger a build.



## Usages


### Submitting Application

1. Create a new Docker image, adding your JAR:

Dockerfile:

```
FROM argussecurity/spark-mesos-oraclejdk
ADD <app-jar> /<app-jar>
```

Command:

`docker build -t <app-docker> .`


2. Run Docker:

`docker run --net host <app-docker> spark-submit --master mesos://<mesos-master-host>:<port> --deploy-mode client --conf spark.mesos.executor.docker.image=<app-docker> --class <main-class> /<app-jar>`

Spark driver, as well as the executors, will run inside the Docker container.


### Spark Shell

docker run --rm -it --net host argussecurity/spark-mesos-oraclejdk spark-shell --master mesos://master.mesos:5050
