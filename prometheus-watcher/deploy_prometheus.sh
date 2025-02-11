docker run -it \
    --name=prometheus_watcher \
    --net=host \
    -p 9090:9090 \
    -v ./prometheus.yml:/prometheus/prometheus.yml \
    prom/prometheus 