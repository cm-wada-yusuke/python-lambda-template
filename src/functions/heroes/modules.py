# -*- coding: utf-8 -*-
# import sys
import configparser
import os
import boto3

conf_file = os.environ['env'] + ".ini"
config = configparser.SafeConfigParser()

try:
    config.read(conf_file)

    hero_table_name = config.get('DynamoDB', 'table_name')
except Exception as error :
    print("Error occured")
    # sys.exit()

class HeroTable:
    def __init__(self, table_name, table):
        self.table_name = table_name
        self.table = table

def dynamoDB():

    dynamo = boto3.resource('dynamodb')
    hero_table = HeroTable(
        hero_table_name,
        dynamo.Table(hero_table_name)
    )
    return hero_table
