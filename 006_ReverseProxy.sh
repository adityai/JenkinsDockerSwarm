docker service create --name proxy \
    -p 80:80 -p 443:443 -p 8080:8080 --network proxy \
    -e MODE=swarm vfarcic/docker-flow-proxy

docker service ps proxy

curl "$(docker-machine ip swarm-1):8080/v1/docker-flow-proxy/reconfigure?serviceName=go-demo&servicePath=/demo&port=8080"

curl -i $(docker-machine ip swarm-1)/demo/hello

