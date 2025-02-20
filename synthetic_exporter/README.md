# Exporters setup
The exporters ended up being kind costy to run on a single machine, so i decided
to use docker swarm to spread the work across multiple nodes

## How to run
1. First build the image and export to dockerhub
```sh
./build_and_push.sh
```
2. Them, create a new docker swarm node and set it up
```sh
./setup_swarm_node <YOU_TOKEN> <MANAGER_ADDR>
```
3. Finally, you can run it. Run the command on the manager
```sh
./deploy_docker_swarm.sh <NUMEBER_NODES>
```