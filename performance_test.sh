#!/bin/bash
TIME_SERIES_COUNT=100_000
REPLICA_COUNT=10
REPLICA_PORT=8000
IMAGE=synthetic-exporter
DOCKER_NETWORK=stress_test
EXPORTER_PORT=8000
EXPORTER_NAME=synthetic-exporter


build_exporters(){
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

rule_files:
  - "alert_rules.yml"

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
    docker build -t $IMAGE .
    docker network create $DOCKER_NETWORK
}

run_prometheus(){
    docker run -d \
        --name=prometheus_stress_test \
        --network=$DOCKER_NETWORK \
        -p 9090:9090 \
        -v $(pwd)/prometheus.yml:/etc/prometheus/prometheus.yml \
        -v $(pwd)/alert_rules.yml:/etc/prometheus/alert_rules.yml \
        prom/prometheus
}

get_prometheus_load(){
    docker stats prometheus_stress_test --no-stream --format "table {{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"
}

stop_prometheus(){
    docker stop prometheus_stress_test
    docker rm prometheus_stress_test
}

stop_exporters(){
    for i in $(seq 1 $REPLICA_COUNT); do
        docker rm -f synthetic-exporter-$i
    done
}


# replica_counts=(1 10 100 1_000)
# time_series_count=(100 1_000 10_000 100_000 1_000_000)
setup_docker
replica_counts=(1 10)
time_series_count=(100 1_000)

for time_series in "${time_series_count[@]}"; do
    echo "Running test with $time_series time series"
    for replica in "${replica_counts[@]}"; do
        echo "Running test with $replica replicas"
        TIME_SERIES_COUNT=$time_series
        REPLICA_COUNT=$replica
        build_exporters
        build_prometheus_file
        run_prometheus
        sleep 60
        get_prometheus_load > prometheus_load_${time_series}_${replica}.txt
        stop_prometheus
        stop_exporters
    done
done