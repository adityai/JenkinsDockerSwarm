docker network create --driver overlay proxy

docker network create --driver overlay go-demo

docker service create --name go-demo-db --network go-demo mongo

docker service ls

docker service create --name go-demo -e DB=go-demo-db \
    --network go-demo --network proxy vfarcic/go-demo

docker service ps go-demo

