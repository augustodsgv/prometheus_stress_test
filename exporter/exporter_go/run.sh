#!/bin/bash
PORT=8000
docker build -t synthetic-exporter .
docker run -d --name synthetic-exporter-go \
    -p $PORT:$PORT \
    -e PORT=$PORT \
    -e METRICS_BASE_NAME="synthetic_metric" \
    -e METRIC_COUNT="1000" \
    -e LABEL_COUNT="2" \
    -e LABEL_VALUES_COUNT="10" \
    -e REFRESH_INTERVAL="10" \
    -e SE_LABEL_FOO="foo" \
    -e SE_LABEL_BAR="bar" \
    synthetic-exporter