#Create swarm-1, swarm-2, swarm-3 virualboxes
for i in 1 2 3; do
    docker-machine create -d virtualbox swarm-$i
done

