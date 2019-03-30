#To connect your Docker Client to the Docker Engine running on the virtual machine, run: docker-machine env swarm-1
eval $(docker-machine env swarm-1)

#Create a container for the visualizer
docker run --name visualizer -d \
    -p 8080:8080 \
    -e HOST=$(docker-machine ip swarm-1) \
    -e PORT=8080 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    dockersamples/visualizer

#Verify in the browser
open http://$(docker-machine ip swarm-1):8080

