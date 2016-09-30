docker run --name visualizer -d \
    -p 8083:8083 \
    -e HOST=$(docker-machine ip swarm-test-1) \
    -e PORT=8083 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    manomarks/visualizer

open http://$(docker-machine ip swarm-test-1):8083


