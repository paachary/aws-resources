import boto3
dynamodb = boto3.resource('dynamodb', 'ap-south-1')


def drop_table(table_name):
    table = dynamodb.Table(table_name)
    print("Deleting contents and table :{} ...".format(table_name))
    table.delete()
    print("Table {}  dropped ...".format(table_name))


drop_table('ProductCatalog')
drop_table('Forum')
drop_table('Reply')
drop_table('Thread')
