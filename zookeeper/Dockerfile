ARG INPUT_DOCKER_REGISTRY=andahme

ARG INPUT_JAVA_MAJOR=11

ARG INPUT_ZOOKEEPER_VERSION=3.6.1


ARG ZOOKEEPER_ARTIFACT=https://downloads.apache.org/zookeeper/zookeeper-${INPUT_ZOOKEEPER_VERSION}/apache-zookeeper-${INPUT_ZOOKEEPER_VERSION}-bin.tar.gz



FROM ${INPUT_DOCKER_REGISTRY}/debian:base AS distribution

ARG ZOOKEEPER_ARTIFACT


ADD ${ZOOKEEPER_ARTIFACT} /tmp/zookeeper.tar.gz

RUN tar -zxf /tmp/zookeeper.tar.gz -C /opt --strip-component=1 \
      --exclude=contrib \
      --exclude=docs \
      --exclude=dist-maven \
      --exclude=src



FROM ${INPUT_DOCKER_REGISTRY}/openjdk-jre:${INPUT_JAVA_MAJOR}-base AS zookeeper

ARG INPUT_ZOOKEEPER_VERSION


EXPOSE 2181

EXPOSE 2888

EXPOSE 3888


ENV ZOOKEEPER_HOME /opt/apache-zookeeper-${INPUT_ZOOKEEPER_VERSION}-bin

ENV PATH ${ZOOKEEPER_HOME}/bin:${PATH}


COPY --from=distribution /opt ${ZOOKEEPER_HOME}

COPY docker-entrypoint.sh /docker-entrypoint.sh


RUN useradd --comment "ZooKeeper User" --create-home --uid 1011 zookeeper

RUN sed -i -e "s/^\\(dataDir=\\).*/\1\/var\/lib\/zookeeper/g" -e "s/^\\(initLimit=\\).*/\130/g" ${ZOOKEEPER_HOME}/conf/zoo_sample.cfg

RUN mkdir ${ZOOKEEPER_HOME}/logs /var/lib/zookeeper && \
    chown -R zookeeper ${ZOOKEEPER_HOME}/conf ${ZOOKEEPER_HOME}/logs /var/lib/zookeeper


VOLUME /var/lib/zookeeper


ENTRYPOINT [ "/docker-entrypoint.sh" ]

CMD [ "zkServer.sh", "start-foreground" ]

USER zookeeper

