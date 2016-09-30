eval $(docker-machine env swarm-1)

mkdir -p docker/jenkins

docker service create --name jenkins --reserve-memory 300m \
    -p 8082:8080 -p 50000:50000 -e JENKINS_OPTS="--prefix=/jenkins" \
    --mount "type=bind,source=$PWD/docker/jenkins,target=/var/jenkins_home" \
    jenkins:alpine

docker service ps jenkins

