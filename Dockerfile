# BUILD: docker build -t test-java .
# RUN:   docker run --env-file local.env -t -i -v $PWD:/app -p 9000:9000  -p 8091:8091 test-java 
#        (run the previous line in your development folder, so the code will be updated)
#
# If "permission denied" on activator, run:
# su -c "chcon -Rt svirt_sandbox_file_t <local path to data in the host>"
#
FROM debian:stable 

MAINTAINER Dani Perez

RUN \
  export DEBIAN_FRONTEND=noninteractive && \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get -y install \
  vim wget curl \
  openjdk-7-jre-headless openjdk-7-jdk \ 
  unzip \
  procps \
  python2.7 \
  python2.7-dev \ 
  python-pip  &&\
  update-alternatives --config javac

EXPOSE 9000

ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64

WORKDIR /app

ADD . /app/ 

ADD requirements.txt /requirements.txt

RUN pip install -r /requirements.txt

RUN ./activator update compile

RUN container-transform docker-compose.yml > /aws-ecs.json

CMD ./gradlew run

