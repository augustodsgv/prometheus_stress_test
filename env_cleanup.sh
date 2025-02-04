DOCKER_NETWORK=stress_test
REPLICA_COUNT=50

destroy_exporters(){
    for i in $(seq 1 $REPLICA_COUNT); do
        docker rm -f synthetic-exporter-$i
    done
}

destroy_prometheus(){
    docker rm -f prometheus_stress_test
}

teardown_docker(){
    docker network rm $DOCKER_NETWORK
}
destroy_exporters
destroy_prometheus
teardown_docker
