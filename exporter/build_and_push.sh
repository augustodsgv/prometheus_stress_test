#!/bin/bash
exporter='exporter_go'
# Builds the image and pushes to dockerhub
IMAGE=synthetic-exporter
USER=augustodsgv
docker build -t ${USER}/${$IMAGE} ./$exporter
docker push ${USER}/${$IMAGE}