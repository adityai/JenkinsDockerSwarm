#Initialize a swarm. The docker engine targeted by this command becomes a manager in the newly created single-node swarm.
docker swarm init --advertise-addr $(docker-machine ip swarm-1)

#Manage join tokens?
TOKEN=$(docker swarm join-token -q manager)

for i in 2 3; do
  eval $(docker-machine env swarm-$i)

  docker swarm join --token $TOKEN \
      --advertise-addr $(docker-machine ip swarm-$i) \
      $(docker-machine ip swarm-1):2377
done

eval $(docker-machine env swarm-1)

docker node ls

