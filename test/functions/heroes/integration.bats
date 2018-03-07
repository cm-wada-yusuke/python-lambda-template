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

    actual=`sam local invoke --docker-network ${docker_network_id} -t template_heroes.yaml --event test/functions/heroes/examples/get_payload.json --env-vars environments/sam-local.json GetHeroes | jq -r .`

    echo $actual
    echo "${actual}" | jq .created_at
    echo "${expected}" | jq .created_at.N
    [ `echo "${actual}" | jq .id` = `echo "${expected}" | jq .id.S` ]
    [ `echo "${actual}" | jq .name` = `echo "${expected}" | jq .name.S` ]
    [ `echo "${actual}" | jq .created_at` -eq  `echo "${expected}" | jq .created_at.N | bc` ]
    [ `echo "${actual}" | jq .updated_at` -eq `echo "${expected}" | jq .updated_at.N | bc` ]
    [ `echo "${actual}" | jq .office` = `echo "${expected}" | jq .office.S` ]
}

@test "DynamoDB PUT Funciton response code is 200" {
    result=`sam local invoke --docker-network ${docker_network_id} -t template_heroes.yaml --event test/functions/heroes/examples/put_payload.json --env-vars environments/sam-local.json PutHeroes | jq '.ResponseMetadata.HTTPStatusCode'`
    [ $result -eq 200 ]
}
