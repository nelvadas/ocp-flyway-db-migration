FROM alpine 
MAINTAINER "Nono Elvadas" 


ENV FLYWAY_VERSION=4.2.0

ENV FLYWAY_HOME=/opt/flyway/$FLYWAY_VERSION  \
    FLYWAY_PKGS="https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/${FLYWAY_VERSION}/flyway-commandline-${FLYWAY_VERSION}.tar.gz"


LABEL com.redhat.component="flyway" \
      io.k8s.description="Platform for upgrading database using flyway" \
      io.k8s.display-name="DB Migration with flyway	" \
      io.openshift.tags="builder,sql-upgrades,flyway,db,migration" 


RUN apk add --update \
       openjdk8-jre \
        wget \
        bash

#Download and flyway
RUN wget --no-check-certificate  $FLYWAY_PKGS &&\
   mkdir -p $FLYWAY_HOME && \
   tar -xzf flyway-commandline-4.2.0.tar.gz -C $FLYWAY_HOME  --strip-components=1 &&\
   chmod 700 $FLYWAY_HOME/flyway && \
   ln -s $FLYWAY_HOME/sql /opt/flyway/sql

VOLUME /opt/flyway/sql

ENTRYPOINT $FLYWAY_HOME/flyway  baseline migrate info  -user=${DB_USER} -password=${DB_PASSWORD} -url=${DB_URL}
