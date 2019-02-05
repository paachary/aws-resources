import boto3
import json
from boto3.dynamodb.conditions import Key, Attr

dynamodb = boto3.resource('dynamodb', region_name='ap-south-1')

table = dynamodb.Table('ProductCatalog')

fe = Key('Price').gt('10') & Key('ProductCategory').eq('Bicycle')
pe = "Price, Title, Brand"
esk = None


response = table.scan(
    FilterExpression=fe,
    ProjectionExpression=pe
    )

for i in response['Items']:
    print(json.dumps(i))

while 'LastEvaluatedKey' in response:
    response = table.scan(
        ProjectionExpression=pe,
        FilterExpression=fe,
        ExclusiveStartKey=response['LastEvaluatedKey']
        )

    for i in response['Items']:
        print(json.dumps(i))
