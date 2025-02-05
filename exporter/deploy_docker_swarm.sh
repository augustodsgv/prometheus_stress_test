#!/bin/bash

# This script deploys many exporters across the docker swarm cluster.
# Swarm is used to prevent the need to manually deploy to each node.
# Swarm is also used to spread the exporters evenly across the cluster nodes.
# 

# Global variables
REPLICA_COUNT=$1        # Get from envvar
if [ -z "$REPLICA_COUNT" ]; then
    echo "Usage: $0 <replica_count>"
    exit 1
fi
IMAGE=augustodsgv/synthetic-exporter
METRIC_COUNT=1000
LABEL_COUNT=2
LABEL_VALUES_COUNT=10
REFRESH_INTERVAL=10
REGISTRY_HOST=127.0.0.1
REGISTRY_PORT=5000
EXPORTER_BASE_NAME=synthetic-exporter
EXPORTER_BASE_PORT=8000


deploy_many_exporters(){
    for ((i=0; i<REPLICA_COUNT;i++)); do
        exporter_name=${EXPORTER_BASE_NAME}_$i
        exporter_port=$((EXPORTER_BASE_PORT + i))
        deploy_exporter $exporter_name $exporter_port $i
    done
}

deploy_exporter(){
    NAME=$1
    PORT=$2
    INDEX=$3
    docker service create \
        -d \
        --name=$NAME \
        -e PORT=8000 \
        -e METRICS_BASE_NAME="synthetic_metric" \
        -e METRIC_COUNT=$METRIC_COUNT \
        -e LABEL_COUNT=$LABEL_COUNT \
        -e LABEL_VALUES_COUNT=$LABEL_VALUES_COUNT \
        -e REFRESH_INTERVAL=$REFRESH_INTERVAL \
        -e SE_LABEL_FOO="foo" \
        -e SE_LABEL_INDEX=$INDEX \
        --publish published=$PORT,target=8000 \
        $IMAGE &
}

deploy_many_exporters