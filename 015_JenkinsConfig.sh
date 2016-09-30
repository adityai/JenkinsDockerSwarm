open http://$(docker-machine ip swarm-1):8082/jenkins/configure

docker-machine ip swarm-1

echo "Click 'Environment Variables', click 'Add'"
echo "Type PROD_IP as 'Name', paste the output as 'Value'"
echo "Click 'Add'"
echo "Type PROD_NAME as 'Name', type 'swarm-1' as 'Value'"
echo "Click 'Save'"
