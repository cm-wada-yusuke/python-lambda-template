#!/usr/bin/env bats

setup() {
    echo "setup"
    aws --endpoint-url=http://localhost:4569 dynamodb create-table --table-name CM-Offices --attribute-definitions AttributeName=id,AttributeType=S --key-schema AttributeName=id,KeyType=HASH --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 || true
    docker_network_id=`docker network ls -q -f NAME=$DOCKER_NAME`
}

teardown() {
    echo "teardown"
}

@test "DynamoDB Get Office Function response the correct item" {
    data='{
        "id": {"S": "test-office-id"},
        "name": {"S": "Saitama"},
        "created_at": {"N": "1520400553"},
        "updated_at": {"N": "1520400554"},
        "address": {"S": "Omiya,Saitama"} }'

    expected=`echo "${data}" | jq -r .`

    aws --endpoint-url=http://localhost:4569 dynamodb put-item --table-name CM-Offices --item "${data}"

    actual=`sam local invoke --docker-network ${docker_network_id} -t template_offices.yaml --event test/functions/offices/examples/get_payload.json --env-vars environments/sam-local.json GetOffices | jq -r .`

    echo "${actual}" | jq .address
    echo "${expected}" | jq .address.S
    [ `echo "${actual}" | jq .id` = `echo "${expected}" | jq .id.S` ]
    [ `echo "${actual}" | jq .name` = `echo "${expected}" | jq .name.S` ]
    [ `echo "${actual}" | jq .created_at` -eq  `echo "${expected}" | jq .created_at.N | bc` ]
    [ `echo "${actual}" | jq .updated_at` -eq `echo "${expected}" | jq .updated_at.N | bc` ]
    [ `echo "${actual}" | jq .address` = `echo "${expected}" | jq .address.S` ]
}

@test "DynamoDB PUT Office Function response code is 200" {
    result=`sam local invoke --docker-network ${docker_network_id} -t template_offices.yaml --event test/functions/offices/examples/put_payload.json --env-vars environments/sam-local.json PutOffices | jq '.ResponseMetadata.HTTPStatusCode'`
    [ $result -eq 200 ]
}
