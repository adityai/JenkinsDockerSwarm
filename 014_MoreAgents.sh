docker-machine create -d virtualbox swarm-test-2

docker-machine ssh swarm-test-2

sudo mkdir -p /workspace && sudo chmod 777 /workspace && exit

TOKEN=$(docker swarm join-token -q manager)

eval $(docker-machine env swarm-test-2)

docker swarm join --token $TOKEN --advertise-addr $(docker-machine ip swarm-test-2) $(docker-machine ip swarm-test-1):2377

docker service ps jenkins-agent

open http://$(docker-machine ip swarm-1):8082/jenkins/computer/

