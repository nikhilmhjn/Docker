FROM ubuntu
MAINTAINER hari446

RUN apt-get update && apt-get install -y python-software-properties software-properties-common
RUN add-apt-repository ppa:webupd8team/java

# install jdk
RUN echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 boolean true" | debconf-set-selections

# install jdk maven svn git
RUN apt-get update && apt-get install -y oracle-java8-installer maven subversion git 

RUN apt-get update && \
    apt-get install -yq --no-install-recommends wget pwgen ca-certificates && \
   apt-get clean && \
    rm -rf /var/lib/apt/lists/*
ENV TOMCAT_MAJOR_VERSION 8
ENV TOMCAT_MINOR_VERSION 8.0.11
ENV CATALINA_HOME /tomcat

RUN wget -q https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz && \
                wget -qO- https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz.md5 | md5sum -c - && \
                tar zxf apache-tomcat-*.tar.gz && \
               rm apache-tomcat-*.tar.gz && \
               mv apache-tomcat* tomcat

ADD create_tomcat_admin_user.sh /create_tomcat_admin_user.sh
RUN mkdir /usr/local/tomcat
ADD run.sh /usr/local/tomcat/run
RUN chmod +x /*.sh
RUN chmod +x /usr/local/tomcat/run

EXPOSE 8080

ADD . /usr/local/ServletDemo
RUN cd /usr/local/ServletDemo &&  mvn clean install
RUN cp /usr/local/ServletDemo/target/*.war /tomcat/webapps/
CMD ["catalina.sh", "run"]
