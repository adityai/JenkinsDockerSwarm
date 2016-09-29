# JenkinsDockerSwarm

Every command listed below is from the extremely organized presentation from http://vfarcic.github.io/jenkins-swarm/index.html. I am trying to understand every single command and document the steps with some details. The <TODO> tags are placeholders where I plan to add details.

# Nodes setup
## Create three swarm machines swarm-1, swarm-2, swarm-3

for i in 1 2 3; do
  docker-machine create -d virtualbox swarm-$i
done

# Swarm Visualizer
## <TODO>
eval $(docker-machine env swarm-1)

## Create visualizer container to visualize the swarm cluster
docker run --name visualizer -d \
  -p 8083:8083 \
  -e HOST=$(docker-machine ip swarm-1) \
  -e PORT=8083 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  manomarks/visualizer

## Open the swarm-1 http url
open http://$(docker-machine ip swarm-1):8083

# Cluster setup
## Initialize the swarm with the IP Address of swarm-1 as the leader
docker swarm init --advertise-addr $(docker-machine ip swarm-1)

TOKEN=$(docker swarm join-token -q manager)

## Join each swarm machine to the cluster
for i in 2 3; do
  eval $(docker-machine env swarm-$i)

  docker swarm join --token $TOKEN \
  --advertise-addr $(docker-machine ip swarm-$i) \
  $(docker-machine ip swarm-1):2377
done

eval $(docker-machine env swarm-1)

## List all nodes in the cluster
docker node ls

# Registry

eval $(docker-machine env swarm-1)

## Create registry container
docker service create --name registry -p 5000:5000 \
  --mount "type=bind,source=$PWD,target=/var/lib/registry" \
  --reserve-memory 100m registry

## Display current status of registry container
docker service ps registry

# Create services
## <TODO>
docker network create --driver overlay proxy

docker network create --driver overlay go-demo

docker service create --name go-demo-db --network go-demo mongo

docker service ls

docker service create --name go-demo -e DB=go-demo-db \
  --network go-demo --network proxy vfarcic/go-demo

docker service ps go-demo

# Reverse Proxy

docker service create --name proxy \
  -p 80:80 -p 443:443 -p 8080:8080 --network proxy \
  -e MODE=swarm vfarcic/docker-flow-proxy

docker service ps proxy

curl "$(docker-machine ip swarm-1):8080/v1/docker-flow-proxy/reconfigure?serviceName=go-demo&servicePath=/demo&port=8080"

curl -i $(docker-machine ip swarm-1)/demo/hello

# Continuous deployment
## Jenkins service

eval $(docker-machine env swarm-1)

mkdir -p docker/jenkins

### Create Jenkins container
docker service create --name jenkins --reserve-memory 300m \
  -p 8082:8080 -p 50000:50000 -e JENKINS_OPTS="--prefix=/jenkins" \
  --mount "type=bind,source=$PWD/docker/jenkins,target=/var/jenkins_home" \
  jenkins:alpine

docker service ps jenkins

# Jenkins setup
open http://$(docker-machine ip swarm-1):8082/jenkins

cat docker/jenkins/secrets/initialAdminPassword

-Paste the output
-Select "Install suggested plugins"
-Type "admin" as both user and password.
-Fill in the rest of the fields and press "Save And Finish".
-Click "Start Using Jenkins"

# Jenkins swarm plugin

open http://$(docker-machine ip swarm-1):8082/jenkins/pluginManager/available

-Select "Self-Organizing Swarm Plug-in Modules"
-Click "Install without restart"

# Jenkins failover
NODE=$(docker service ps -f desired-state=running jenkins \
  | tail +2 | awk '{print $4}')

eval $(docker-machine env $NODE)

docker rm -f $(docker ps -qa -f "ancestor=jenkins:alpine")

docker service ps jenkins

open http://$(docker-machine ip swarm-1):8082/jenkins

## Agents cluster
docker-machine create -d virtualbox swarm-test-1

docker-machine ssh swarm-test-1

sudo mkdir -p /workspace && sudo chmod 777 /workspace && exit

eval $(docker-machine env swarm-test-1)

docker swarm init --advertise-addr $(docker-machine ip swarm-test-1)

# Visualizer

docker run --name visualizer -d \
  -p 8083:8083 \
  -e HOST=$(docker-machine ip swarm-test-1) \
  -e PORT=8083 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  manomarks/visualizer

open http://$(docker-machine ip swarm-test-1):8083

# Agent container
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

## More agents
docker-machine create -d virtualbox swarm-test-2

docker-machine ssh swarm-test-2

sudo mkdir -p /workspace && sudo chmod 777 /workspace && exit

TOKEN=$(docker swarm join-token -q manager)

eval $(docker-machine env swarm-test-2)

docker swarm join --token $TOKEN --advertise-addr $(docker-machine ip swarm-test-2) $(docker-machine ip swarm-test-1):2377

docker service ps jenkins-agent

open http://$(docker-machine ip swarm-1):8082/jenkins/computer/

# Registry

docker service create --name registry -p 5000:5000 \
  --mount "type=bind,source=$PWD,target=/var/lib/registry" \
  --reserve-memory 100m registry

docker service ps registry

# Jenkins pipeline job

Click "New Item"
Type "go-demo", select "Pipeline", click "OK"

```

node("docker") {

  git "https://github.com/vfarcic/go-demo.git"

  stage("Unit") {
  sh "docker-compose -f docker-compose-test.yml run --rm unit"
  sh "docker build -t go-demo ."
  }

  stage("Staging") {
  try {
  sh "docker-compose -f docker-compose-test-local.yml up -d staging-dep"
  sh "HOST_IP=localhost docker-compose -f docker-compose-test-local.yml run --rm staging"
  } catch(e) {
  error "Staging failed"
  } finally {
  sh "docker-compose -f docker-compose-test-local.yml down"
  }
  }

  stage("Publish") {
  sh "docker tag go-demo localhost:5000/go-demo:2.${env.BUILD_NUMBER}"
  sh "docker push localhost:5000/go-demo:2.${env.BUILD_NUMBER}"
  }

  stage("Prod-like") {
  echo "A production-like cluster is yet to be created"
  }

  stage("Production") {
  withEnv([
  "DOCKER_TLS_VERIFY=1",
  "DOCKER_HOST=tcp://${env.PROD_IP}:2376",
  "DOCKER_CERT_PATH=/machines/${env.PROD_NAME}"
  ]) {
  sh "docker service update --image localhost:5000/go-demo:2.${env.BUILD_NUMBER} go-demo"
  }
  sh "HOST_IP=${env.PROD_IP} docker-compose -f docker-compose-test-local.yml run --rm production"
  }
}

# Run
eval $(docker-machine env swarm-1)

docker service ps go-demo

# Cleanup
docker-machine rm -f \
  swarm-1 swarm-2 swarm-3 swarm-test-1 swarm-test-2

rm -rf docker
