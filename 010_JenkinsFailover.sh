NODE=$(docker service ps -f desired-state=running jenkins \
    | tail +2 | awk '{print $4}')

eval $(docker-machine env $NODE)

docker rm -f $(docker ps -qa -f "ancestor=jenkins:alpine")

docker service ps jenkins

open http://$(docker-machine ip swarm-1):8082/jenkins

