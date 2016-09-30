docker service create --name registry -p 5000:5000 \
    --mount "type=bind,source=$PWD,target=/var/lib/registry" \
    --reserve-memory 100m registry

docker service ps registry

echo "Jenkins Pipeline Job"
echo "Click 'New Item'"
echo "Type 'go-demo', select "Pipeline", click 'Ok'"

