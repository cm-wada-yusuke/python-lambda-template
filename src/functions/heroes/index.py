"""This is python3.6 program."""

import boto3
import datetime
import uuid
from builtins import Exception
import os
from src.functions.heroes.utils import *

DYNAMODB_ENDPOINT = os.getenv('DYNAMODB_ENDPOINT')
HERO_TABLE_NAME = os.getenv('HERO_TABLE_NAME')

print(DYNAMODB_ENDPOINT)
print(HERO_TABLE_NAME)

DYNAMO = boto3.resource(
    'dynamodb',
    endpoint_url=DYNAMODB_ENDPOINT
)

DYNAMODB_TABLE = DYNAMO.Table(HERO_TABLE_NAME)


def get(event, context):
    try:
        # get DeviceSerialID
        hero_id = event['id']

        response = DYNAMODB_TABLE.get_item(
            Key={
                'id': hero_id
            }
        )

        return response

    except Exception as error:
        raise error

def put(event, context):
    try:
        hero_id = str(uuid.uuid4())

        name = event.get('name')
        office = event.get('office')
        updated_at = epoc_by_second_precision(datetime.now())

        response = DYNAMODB_TABLE.put_item(
            Item={
                'id': hero_id,
                'name': name,
                'office': office,
                'updated_at': updated_at,
                'created_at': updated_at,
            }
        )
        return response
    except Exception as error:
        raise error