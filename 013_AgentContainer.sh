mkdir -p docker/jenkins/workspace

export USER=admin && export PASSWORD=admin

docker service create --name jenkins-agent \
    -e COMMAND_OPTIONS="-master http://$(docker-machine ip swarm-1):8082/jenkins -username $USER -password $PASSWORD -labels 'docker' -executors 5" \
    --mount "type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock" \
    --mount "type=bind,source=/workspace,target=/workspace" \
    --mount "type=bind,source=$HOME/.docker/machine/machines,target=/machines" \
    --mode global vfarcic/jenkins-swarm-agent

docker service ps jenkins-agent

open http://$(docker-machine ip swarm-1):8082/jenkins/computer/

