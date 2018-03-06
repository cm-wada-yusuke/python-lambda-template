#!/usr/bin/env bats

. environments/common.sh

setup() {
    echo "setup"
    docker_network_id=`docker network ls -q -f NAME=$DOCKER_NAME`
}

teardown() {
    echo "teardown"
}

@test "DynamoDB PUT Funciton response code is 200" {
  echo $docker_network_id
  result=`sam local invoke --docker-network ${docker_network_id} -t template_heroes.yaml --event test/functions/heroes/examples/get_payload.json --env-vars environments/sam-local.json GetHeroes | jq '.ResponseMetadata.HTTPStatusCode'`
  [ $result -eq 200 ]
}
