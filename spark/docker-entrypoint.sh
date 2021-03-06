#!/bin/bash
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# echo commands to the terminal output
set -ex

SPARK_K8S_CMD="$1"
case "$SPARK_K8S_CMD" in
    driver | executor)
      shift 1
      ;;
    "")
      ;;
    *)
      echo "Non-spark-on-k8s command provided, proceeding in pass-through mode..."
      exec "$@"
      ;;
esac

SPARK_CLASSPATH="$SPARK_CLASSPATH:${SPARK_HOME}/jars/*"
env | grep SPARK_JAVA_OPT_ | sort -t_ -k4 -n | sed 's/[^=]*=\(.*\)/\1/g' > /tmp/java_opts.txt
readarray -t SPARK_EXECUTOR_JAVA_OPTS < /tmp/java_opts.txt

if [ -n "$SPARK_EXTRA_CLASSPATH" ]; then
  SPARK_CLASSPATH="$SPARK_CLASSPATH:$SPARK_EXTRA_CLASSPATH"
fi

case "$SPARK_K8S_CMD" in
  driver)
    exec "$SPARK_HOME/bin/spark-submit" \
      --conf "spark.driver.bindAddress=$SPARK_DRIVER_BIND_ADDRESS" \
      --deploy-mode client \
      "$@"
    ;;
  executor)
    exec ${JAVA_HOME}/bin/java \
      "${SPARK_EXECUTOR_JAVA_OPTS[@]}" \
      -Xms$SPARK_EXECUTOR_MEMORY \
      -Xmx$SPARK_EXECUTOR_MEMORY \
      -cp "$SPARK_CLASSPATH" \
      org.apache.spark.executor.CoarseGrainedExecutorBackend \
      --driver-url $SPARK_DRIVER_URL \
      --executor-id $SPARK_EXECUTOR_ID \
      --cores $SPARK_EXECUTOR_CORES \
      --app-id $SPARK_APPLICATION_ID \
      --hostname $SPARK_EXECUTOR_POD_IP
    ;;
  *)
    echo "Unknown command: $SPARK_K8S_CMD" 1>&2
    exit 1
esac

exec "${CMD[@]}"
