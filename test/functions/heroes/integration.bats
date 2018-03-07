#!/usr/bin/env bats

. environments/common.sh

setup() {
    echo "setup"
    docker_network_id=`docker network ls -q -f NAME=$DOCKER_NAME`
}

teardown() {
    echo "teardown"
}

@test "DynamoDB Get Funciton response the correct item" {
   data='{
        "id": {"S": "test-id"},
        "name": {"S": "Test-man"},
        "created_at": {"N": "1520400553"},
        "updated_at": {"N": "1520400554"},
        "office": {"S": "virtual"} }'

   expected=`echo "${data}" | jq -r .`

   aws --endpoint-url=http://localhost:4569 dynamodb put-item --table-name CM-Heroes --item "${data}"

  result=`sam local invoke --docker-network ${docker_network_id} -t template_heroes.yaml --event test/functions/heroes/examples/get_payload.json --env-vars environments/sam-local.json GetHeroes | jq -r .Item`

  [ $result -eq $expected ]
}

@test "DynamoDB PUT Funciton response code is 200" {
  result=`sam local invoke --docker-network a27c0476cb8e -t template_heroes.yaml --event test/functions/heroes/examples/put_payload.json --env-vars environments/sam-local.json PutHeroes | jq '.ResponseMetadata.HTTPStatusCode'`
  [ $result -eq 200 ]
}
