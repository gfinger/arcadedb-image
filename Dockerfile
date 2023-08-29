FROM ubuntu:latest
RUN apt-get update
RUN apt-get install -y apt-utils build-essential sudo git wget zsh unzip
RUN apt-get install -y openjdk-11-jdk
RUN apt-get install -y maven

ENV ARCADEDB_VERSION=23.7.1
ENV GREMLIN_SERVER_VERSION=3.6.5
ENV OPENCYPHER_VERSION=9.0.20190305

RUN mkdir /install
WORKDIR /install
RUN git clone https://github.com/ArcadeData/arcadedb.git

WORKDIR /install/arcadedb
RUN git fetch --all --tags --prune
RUN git checkout tags/${ARCADEDB_VERSION} -b ${ARCADEDB_VERSION}
RUN mvn clean install -DskipTests
RUN mvn dependency:copy-dependencies -DoutputDirectory=/install/arcadedb/package/target/arcadedb-${ARCADEDB_VERSION}.dir/arcadedb-${ARCADEDB_VERSION}/lib

WORKDIR /install

RUN cd arcadedb/package/target/arcadedb-${ARCADEDB_VERSION}.dir/arcadedb-${ARCADEDB_VERSION} && tar -cf arcadedb.tar . 
RUN mkdir /arcadedb
RUN mv /install/arcadedb/package/target/arcadedb-${ARCADEDB_VERSION}.dir/arcadedb-${ARCADEDB_VERSION}/arcadedb.tar /arcadedb
# RUN rm -r /install
RUN cd /arcadedb && tar -xf arcadedb.tar

WORKDIR /arcadedb
RUN rm arcadedb.tar
RUN rm config/gremlin*

ENV JAVA_OPTS="-Darcadedb.server.rootPassword=playwithdata \
-Darcadedb.server.plugins=Redis:com.arcadedb.redis.RedisProtocolPlugin,MongoDB:com.arcadedb.mongo.MongoDBProtocolPlugin,Postgres:com.arcadedb.postgres.PostgresProtocolPlugin,GremlinServer:com.arcadedb.server.gremlin.GremlinServerPlugin "
ENTRYPOINT ["./bin/server.sh"]

# CMD JAVA_OPTS="-Darcadedb.server.rootPassword=playwithdata \
# -Darcadedb.ha.enabled=true \
# -Darcadedb.ha.serverList=localhost \
# -Darcadedb.server.plugins=Redis:com.arcadedb.redis.RedisProtocolPlugin,MongoDB:com.arcadedb.mongo.MongoDBProtocolPlugin,Postgres:com.arcadedb.postgres.PostgresProtocolPlugin,GremlinServer:com.arcadedb.server.gremlin.GremlinServerPlugin " \
# ./bin/server.sh


