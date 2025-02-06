#!/bin/bash
LOG_FILE=results2.txt
REPLICA_COUNT=100

DOCKER_NETWORK=stress_test
EXPORTER_ADDR=172.18.2.196

EXPORTER_PORT=8000
METRICS_BASE_NAME=synthetic_metric

build_prometheus_yml(){
  echo "Generating prometheus.yml file"

    cat <<EOF > prometheus.yml
global:
  scrape_interval: 1m
rule_files:
  - "alert_rules.yml"
scrape_configs:
  - job_name: 'stress_test'
    metrics_path: /metrics
    scrape_timeout: 20s
    static_configs:
EOF
#   - "recording_rules.yml"

    for i in $(seq 1 $REPLICA_COUNT); do
        echo "      - targets: ['$EXPORTER_ADDR:$(($EXPORTER_PORT + $i))']" >> prometheus.yml
    done
}

build_alert_rules_yml(){
  echo "Generating alert_rules.yml file"

    cat <<EOF > alert_rules.yml
groups:
  - name: stress_test
    rules:
EOF

    for i in $(seq 1 $REPLICA_COUNT); do
        cat <<EOF >> alert_rules.yml
      - alert: high_metric_value_25_$i
        expr: avg(${METRICS_BASE_NAME}_$i) > 25
        for: 5s
        labels:
          severity: info
        annotations:
          summary: High request rate
          description: High request rate detected

      - alert: high_metric_value_50_$i
        expr: avg(${METRICS_BASE_NAME}$i) > 50
        for: 5s
        labels:
          severity: warning
        annotations:
          summary: High request rate
          description: High request rate detected

      - alert: high_metric_value_75_$i
        expr: avg(${METRICS_BASE_NAME}_$i) > 75
        for: 5s
        labels:
          severity: high 
        annotations:
          summary: High request rate
          description: High request rate detected

      - alert: high_metric_value_100_$i
        expr: avg(${METRICS_BASE_NAME}_$i) > 100
        for: 5s
        labels:
          severity: critical
        annotations:
          summary: High request rate
          description: High request rate detected
EOF
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
        -v $(pwd)/alert_rules.yml:/etc/prometheus/alert_rules.yml \
        prom/prometheus
}

get_prometheus_load(){
    docker stats prometheus_stress_test --no-stream --format "table {{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"
}

stop_prometheus(){
    echo "Stoping prometheus container"
    docker stop prometheus_stress_test
    docker rm prometheus_stress_test
}

replica_counts=(1 5 10 50 100 1000)
setup_docker
run_prometheus
build_alert_rules_yml

for replica in "${replica_counts[@]}"; do
    REPLICA_COUNT=$replica
    echo "Running test with $replica replicas"
    echo "Running test with $replica replicas" >> $LOG_FILE
    build_prometheus_yml
    echo "Press any key to jump to next load..."
    read
done