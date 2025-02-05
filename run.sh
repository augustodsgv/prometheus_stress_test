#!/bin/bash
PORT=8000
docker build -t synthetic-exporter .
docker run -d --name synthetic-exporter \
    -p $PORT:$PORT \
    -e PORT=$PORT \
    -e METRIC_NAME="synthetic_metric" \
    -e METRICS_COUNT="100000" \
    -e REFRESH_INTERVAL="10" \
    -e SE_LABEL_FOO="foo" \
    -e SE_LABEL_BAR="bar" \
    synthetic-exporter