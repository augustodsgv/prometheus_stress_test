#!/bin/bash
exporter='exporter_go'
# Builds the image and pushes to dockerhub
IMAGE=synthetic-exporter
USER=augustodsgv
REPO=prometheus_stress_test
docker build -t ghcr.io/$USER/$IMAGE ./$exporter
docker push ghcr.io/$USER/$IMAGE