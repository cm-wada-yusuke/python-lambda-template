"""This is python3.6 program."""

import boto3
import datetime
import uuid
from builtins import Exception
import os
from src.functions.handlers.heroes.utils import *

ENV = os.getenv('ENV')
DYNAMODB_ENDPOINT = os.getenv('DYNAMODB_ENDPOINT')
OFFICE_TABLE_NAME = os.getenv('OFFICE_TABLE_NAME')

print(DYNAMODB_ENDPOINT)
print(OFFICE_TABLE_NAME)

DYNAMO = boto3.resource(
    'dynamodb',
    endpoint_url=DYNAMODB_ENDPOINT
)

DYNAMODB_TABLE = DYNAMO.Table(OFFICE_TABLE_NAME)



def get(event, context):
    try:
        office_id = event['id']

        dynamo_response = DYNAMODB_TABLE.get_item(
            Key={
                'id': office_id
            }
        )

        response = json.dumps(dynamo_response['Item'], cls=DecimalEncoder, ensure_ascii=False)

        return response

    except Exception as error:
        raise error

def put(event, context):
    try:
        office_id = str(uuid.uuid4())

        name = event.get('name')
        address = event.get('address')
        updated_at = epoc_by_second_precision(datetime.now())

        response = DYNAMODB_TABLE.put_item(
            Item={
                'id': office_id,
                'name': name,
                'address': address,
                'updated_at': updated_at,
                'created_at': updated_at,
            }
        )
        return response
    except Exception as error:
        raise error