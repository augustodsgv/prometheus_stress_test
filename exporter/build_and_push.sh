#!/bin/bash
# Builds the image and pushes to dockerhub
IMAGE=synthetic-exporter
USER=augustodsgv
docker build -t ${USER}/${$IMAGE} .
docker push ${USER}/${$IMAGE}