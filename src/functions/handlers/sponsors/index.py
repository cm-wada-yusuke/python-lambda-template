"""This is python3.6 program."""

import boto3
import datetime
import uuid
from builtins import Exception
import os
from core.utils import *

ENV = os.getenv('ENV')
DYNAMODB_ENDPOINT = os.getenv('DYNAMODB_ENDPOINT')
SPONSOR_TABLE_NAME = os.getenv('SPONSOR_TABLE_NAME')

print(DYNAMODB_ENDPOINT)
print(SPONSOR_TABLE_NAME)

DYNAMO = boto3.resource(
    'dynamodb',
    endpoint_url=DYNAMODB_ENDPOINT
)

DYNAMODB_TABLE = DYNAMO.Table(SPONSOR_TABLE_NAME)



def get(event, context):
    try:
        sponsor_id = event['id']

        dynamo_response = DYNAMODB_TABLE.get_item(
            Key={
                'id': sponsor_id
            }
        )

        response = json.dumps(dynamo_response['Item'], cls=DecimalEncoder, ensure_ascii=False)

        return response

    except Exception as error:
        raise error

def put(event, context):
    try:
        sponsor_id = str(uuid.uuid4())

        name = event.get('name')
        address = event.get('address')
        updated_at = epoc_by_second_precision(datetime.now())

        response = DYNAMODB_TABLE.put_item(
            Item={
                'id': sponsor_id,
                'name': name,
                'address': address,
                'updated_at': updated_at,
                'created_at': updated_at,
            }
        )
        return response
    except Exception as error:
        raise error