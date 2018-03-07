"""This is python3.6 program."""

import json
import boto3
import datetime
from boto3.dynamodb.conditions import Key, Attr
from builtins import Exception
import os
from src.functions.heroes.utils import *

DYNAMODB_ENDPOINT = os.environ['DYNAMODB_ENDPOINT']
HERO_TABLE_NAME = os.environ['HERO_TABLE_NAME']

print(DYNAMODB_ENDPOINT)
print(HERO_TABLE_NAME)

DYNAMO = boto3.resource(
    'dynamodb',
    endpoint_url=DYNAMODB_ENDPOINT
)

DYNAMODB_TABLE = DYNAMO.Table(HERO_TABLE_NAME)


# HERO_TABLE = DYNAMO.Table(TABLE_NAME)


# DynamoDB
def get(event, context):
    try:
        # get DeviceSerialID
        hero_id = event['id']

        print("Received event: " + json.dumps(event, indent=2))

        # return {'statusCode': 200, 'body': "Hello " + json.dumps(event['body']),'headers': {'Content-Type': 'application/json'}}

        # response = DYNAMO.query(
        #     TableName='CM-Heroes',
        #     KeyConditionExpression=Key('id').eq(hero_id)
        # )

        # response = DYNAMODB_TABLE.get_item(
        #     Key={
        #         'id': '1'
        #     }
        # )
        print('start')

        updated_at = epoc_by_second_precision(datetime.now())

        response = DYNAMODB_TABLE.put_item(
            Item={
                'id': '1',
                'updated_at': updated_at,
                'created_at': updated_at,
                'modified_at': updated_at
            }
        )

        print('end')
        return response

    except Exception as error:
        raise error
