#!/usr/bin/env bash

cd `dirname $0`

aws --endpoint-url=http://localhost:4569 dynamodb create-table --table-name CM-Heroes --attribute-definitions AttributeName=id,AttributeType=S --key-schema AttributeName=id,KeyType=HASH --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1

find test -name '*.bats' | xargs bats
