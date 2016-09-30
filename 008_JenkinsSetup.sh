open http://$(docker-machine ip swarm-1):8082/jenkins

cat docker/jenkins/secrets/initialAdminPassword

echo "Paste the output."
echo "Install suggested plugins"
echo "Type admin as both user and password."
echo "Fill in the rest of the fields and press 'Save And Finis'h".
echo "Click 'Start Using Jenkins'"

