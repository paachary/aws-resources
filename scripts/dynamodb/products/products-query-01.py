import boto3
import json
import decimal
from boto3.dynamodb.conditions import Key, Attr

# Helper class to convert a DynamoDB item to JSON.
class DecimalEncoder(json.JSONEncoder):
    def default(self, o):
        if isinstance(o, decimal.Decimal):
            if o % 1 > 0:
                return float(o)
            else:
                return int(o)
        return super(DecimalEncoder, self).default(o)

dynamodb = boto3.resource('dynamodb', region_name='ap-south-1')

table = dynamodb.Table("ProductCatalog")

print("{Product Catalog for a particular ID")

response = table.query(
    KeyConditionExpression=Key('Id').eq(103)
)
print("Price : Product Type : Title : Authors")
for i in response['Items']:
    print(i['Price'], ":", i['ProductCategory'],":",i["Title"],":",i["Authors"])
