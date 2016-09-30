eval $(docker-machine env swarm-1)

docker service create --name registry -p 5000:5000 \
    --mount "type=bind,source=$PWD,target=/var/lib/registry" \
    --reserve-memory 100m registry

docker service ps registry

