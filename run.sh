#!/bin/bash
PORT=8000
docker build -t synthetic-exporter .
docker run -d --name synthetic-exporter \
    -p $PORT:$PORT \
    -e PORT=$PORT \
    -e METRIC_NAME="synthetic_metric" \
    -e METRIC_COUNT="10" \
    synthetic-exporter