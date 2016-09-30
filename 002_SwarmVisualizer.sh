eval $(docker-machine env swarm-1)

docker run --name visualizer -d \
    -p 8083:8083 \
    -e HOST=$(docker-machine ip swarm-1) \
    -e PORT=8083 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    manomarks/visualizer

open http://$(docker-machine ip swarm-1):8083

