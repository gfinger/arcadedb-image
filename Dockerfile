FROM ubuntu:latest
RUN apt-get update
RUN apt-get install -y apt-utils build-essential sudo git wget zsh unzip
RUN apt-get install -y openjdk-11-jdk
RUN apt-get install -y maven


RUN mkdir /install
WORKDIR /install
RUN git clone https://github.com/ArcadeData/arcadedb.git

WORKDIR /install/arcadedb
RUN mvn clean install -DskipTests
RUN mvn dependency:copy-dependencies -DoutputDirectory=/install/arcadedb/package/target/arcadedb-${ARCADEDB_VERSION}.dir/arcadedb-${ARCADEDB_VERSION}/lib


ENV ARCADEDB_VERSION=23.1.2-SNAPSHOT
ENV GREMLIN_SERVER_VERSION=3.6.1
ENV OPENCYPHER_VERSION=9.0.20190305

WORKDIR /install

RUN cd arcadedb/package/target/arcadedb-${ARCADEDB_VERSION}.dir/arcadedb-${ARCADEDB_VERSION} && tar -cf arcadedb.tar . 
RUN mkdir /arcadedb
RUN mv /install/arcadedb/package/target/arcadedb-${ARCADEDB_VERSION}.dir/arcadedb-${ARCADEDB_VERSION}/arcadedb.tar /arcadedb
# RUN rm -r /install
RUN cd /arcadedb && tar -xf arcadedb.tar

WORKDIR /arcadedb
RUN rm arcadedb.tar
RUN rm config/gremlin*

CMD JAVA_OPTS="-Darcadedb.server.rootPassword=playwithdata \
-Darcadedb.ha.enabled=true \
-Darcadedb.server.plugins=Redis:com.arcadedb.redis.RedisProtocolPlugin,MongoDB:com.arcadedb.mongo.MongoDBProtocolPlugin,Postgres:com.arcadedb.postgres.PostgresProtocolPlugin,GremlinServer:com.arcadedb.server.gremlin.GremlinServerPlugin " \
./bin/server.sh


