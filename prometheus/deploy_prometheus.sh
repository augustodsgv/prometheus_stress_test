#!/bin/bash

# Array of exporter addresses
EXPORTER_ADDRS=("172.18.3.38" "172.18.1.249" "172.18.0.216" "172.18.1.169" "172.18.3.127" "172.18.1.7" "172.18.3.47" "172.18.2.51")
EXPORTER_BASE_PORT=8000

build_prometheus_yml() {
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

  # Distribute targets among EXPORTER_ADDRS
  for i in $(seq 1 $1); do
    addr_index=$((($i - 1) % ${#EXPORTER_ADDRS[@]}))
    echo "      - targets: ['${EXPORTER_ADDRS[$addr_index]}:$(($EXPORTER_BASE_PORT + $i))']" >> prometheus.yml
  done
}

run_prometheus() {
  docker run -d \
    --name=prometheus_stress_test \
    -p 9090:9090 \
    -v $(pwd)/prometheus.yml:/etc/prometheus/prometheus.yml \
    quay.io/prometheus/prometheus
}

replica_counts=(1 50 100 500 1000 1500 2000 3000)
run_prometheus

for replica in "${replica_counts[@]}"; do
  echo "Running test with $replica replicas"
  build_prometheus_yml $replica
  echo "Press any key to jump to next load..."
  read
  # sleep 1800
  docker restart prometheus_stress_test
done