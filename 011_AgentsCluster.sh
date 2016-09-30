docker-machine create -d virtualbox swarm-test-1

docker-machine ssh swarm-test-1

sudo mkdir -p /workspace && sudo chmod 777 /workspace && exit

eval $(docker-machine env swarm-test-1)

docker swarm init --advertise-addr $(docker-machine ip swarm-test-1)

