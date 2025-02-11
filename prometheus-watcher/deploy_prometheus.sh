docker run -it \
    --name=prometheus_watcher \
    -d \
    -p 9090:9090 \
    -v ./prometheus.yml:/etc/prometheus/prometheus.yml \
    quay.io/prometheus/prometheus 
