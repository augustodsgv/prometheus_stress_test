#!/bin/bash

# Deletes all exporters

# Global variables
REPLICA_COUNT=$1        # Get from envvar
if [ -z "$REPLICA_COUNT" ]; then
    echo "Usage: $0 <replica_count>"
    exit 1
fi
EXPORTER_BASE_NAME=synthetic-exporter

delete_exporters(){
    for ((i=0; i<REPLICA_COUNT;i++)); do
        exporter_name=${EXPORTER_BASE_NAME}_$i
        docker service rm $exporter_name
    done
}

delete_exporters