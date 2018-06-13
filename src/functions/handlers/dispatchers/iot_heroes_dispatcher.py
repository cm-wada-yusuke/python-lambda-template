import os
import boto3
import base64
import json

import logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)


PUT_HEROES_FUNCTION_NAME = os.getenv('PUT_HEROES_FUNCTION_NAME')
PUT_OFFICES_FUNCTION_NAME = os.getenv('PUT_OFFICES_FUNCTION_NAME')
PUT_SPONSORS_FUNCTION_NAME = os.getenv('PUT_SPONSORS_FUNCTION_NAME')

LAMBDA = boto3.client('lambda')


def lambda_handler(event, context):
    for record in event['Records']:
        binary_message = base64.b64decode(record["kinesis"]["data"])
        json_message = json.loads(binary_message.decode('utf-8'))
        topic_name = json_message['topic']

        if 'heroes/activity/heroes' in topic_name:
            function_name = PUT_HEROES_FUNCTION_NAME
        elif 'heroes/activity/offices' in topic_name:
            function_name = PUT_OFFICES_FUNCTION_NAME
        elif 'heroes/activity/sponsors' in topic_name:
            function_name = PUT_SPONSORS_FUNCTION_NAME
        else:
            raise Exception(f'UnknownTopicName:{topic_name}')

        LAMBDA.invoke(
            FunctionName=function_name,
            InvocationType='Event',
            Payload=binary_message
        )
    message = f'Finished: dispatch message to function_name:{function_name}. '
    logger.info(message)
    return message
