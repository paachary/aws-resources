import boto3
import json
import os


s3_client = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')

def lambda_handler(event, context):

    table_name = os.environ["DDB_NAME"]
    dynamoDB_table_name = dynamodb.Table(table_name)

    bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']
    
    json_object = s3_client.get_object(Bucket=bucket, Key=key)
    
    json_file_reader = json_object['Body'].read().decode('utf-8')
    
    dict1 = json_file_reader.split("\n")
    
    for dict2 in dict1:
        dictRow = dict2.strip()
        if (len(dictRow) == 0):
            pass
        else:
            json_dict =  json.loads(dictRow)
            dynamoDB_table_name.put_item(Item = json_dict)