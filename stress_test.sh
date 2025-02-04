TIME_SERIES_COUNT=100_000
REPLICA_COUNT=75
REPLICA_PORT=8000
IMAGE=synthetic-exporter
DOCKER_NETWORK=stress_test
EXPORTER_PORT=8000
EXPORTER_NAME=synthetic-exporter

build_exporters(){
    docker build -t $IMAGE .
    for i in $(seq 1 $REPLICA_COUNT); do
        docker run -d --name $EXPORTER_NAME-$i \
            --network=$DOCKER_NETWORK \
            -p $((30000 + EXPORTER_PORT + i - 1)):$EXPORTER_PORT \
            -e PORT=$EXPORTER_PORT \
            -e METRIC_NAME="synthetic_metric" \
            -e METRICS_COUNT=$TIME_SERIES_COUNT \
            -e SE_LABEL_INDEX=$i \
            $IMAGE
    done
}

build_prometheus_file(){
  echo "Generating prometheus.yml file"

    cat <<EOF > prometheus.yml
global:
  scrape_interval: 25s

scrape_configs:
  - job_name: 'stress_test'
    metrics_path: /metrics
    scrape_timeout: 20s
    static_configs:
EOF

    for i in $(seq 1 $REPLICA_COUNT); do
        echo "      - targets: ['$EXPORTER_NAME-$i:$EXPORTER_PORT']" >> prometheus.yml
    done
}

setup_docker(){
    docker network create $DOCKER_NETWORK
}

run_prometheus(){
    docker run -d \
        --name=prometheus_stress_test \
        --network=$DOCKER_NETWORK \
        -p 9090:9090 \
        -v $(pwd)/prometheus.yml:/etc/prometheus/prometheus.yml \
        prom/prometheus
}

setup_docker
build_exporters
build_prometheus_file
run_prometheus
