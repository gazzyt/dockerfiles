#!/bin/bash -e

ORDNIAL_TEST='^[0-9]+$'

if [ ${KAFKA_BROKER_ID} ]; then
  echo "ANDAHME Initializing - KAFKA_BROKER_ID (${KAFKA_BROKER_ID})"
  sed -i -e "s/^\(broker.id=\).*$/\1${KAFKA_BROKER_ID}/g" ${KAFKA_HOME}/config/server.properties
elif [[ ${HOSTNAME##*-} =~ ${ORDINAL_TEST} ]]; then
  echo "ANDAHME Initializing - KAFKA_BROKER_ID (${HOSTNAME##*-})"
  sed -i -e "s/^\(broker.id=\).*$/\1${HOSTNAME##*-}/g" ${KAFKA_HOME}/config/server.properties
fi

echo "ANDAHME Initializing - KAFKA_ZOOKEEPER_CONNECT (${KAFKA_ZOOKEEPER_CONNECT:-zookeeper:2181})"
sed -i -e "s/^\(zookeeper\.connect=\).*/\1${KAFKA_ZOOKEEPER_CONNECT:-zookeeper:2181}/g" ${KAFKA_HOME}/config/server.properties


exec $@

