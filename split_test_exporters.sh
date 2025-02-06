#!/bin/bash
# Creates 1000 exporters ranging from ports 8000 to 9000
REPLICA_COUNT=1000

LOG_FILE=exporters.txt

IMAGE=synthetic-exporter
DOCKER_NETWORK=stress_test
EXPORTER_NAME=synthetic-exporter

EXPORTER_PORT=8000
METRICS_BASE_NAME=synthetic_metric
METRIC_COUNT=1000
LABEL_COUNT=2
LABEL_VALUES_COUNT=10
REFRESH_INTERVAL=10

build_exporters(){
    echo "Building $REPLICA_COUNT exporter container..."
    for i in $(seq 1 $REPLICA_COUNT); do
        docker run -d --name $EXPORTER_NAME-$i \
            --network=$DOCKER_NETWORK \
            -p $((EXPORTER_PORT + i)):8000 \
            -e PORT=$EXPORTER_PORT \
            -e METRICS_BASE_NAME=$METRICS_BASE_NAME \
            -e METRIC_COUNT=$METRIC_COUNT \
            -e LABEL_COUNT=$LABEL_COUNT \
            -e LABEL_VALUES_COUNT=$LABEL_VALUES_COUNT \
            -e REFRESH_INTERVAL=$REFRESH_INTERVAL \
            -e SE_LABEL_FOO="foo" \
            -e SE_LABEL_BAR="bar" \
            -e SE_LABEL_INDEX=$i \
            $IMAGE
    done
}

setup_docker(){
    docker build -t $IMAGE .
    docker network create $DOCKER_NETWORK
}

stop_exporters(){
    echo "Stoping exporter container..."
    for i in $(seq 1 $REPLICA_COUNT); do
        docker rm -f synthetic-exporter-$i
    done
}

setup_docker

build_exporters

echo "Press any key to teaa down the test"
read
stop_exporters