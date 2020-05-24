
import boto3
dynamodb = boto3.resource('dynamodb', 'ap-south-1')
table_name = 'ProductCatalog'
print("Creating table {0} ...".format(table_name))
table = dynamodb.create_table(TableName = table_name,
                          AttributeDefinitions=
                          [
                                   {
                                      'AttributeName' : 'Id',
                                      'AttributeType' : 'N'
                                   },
                          ],
                          KeySchema=
                          [
                             {
                                'AttributeName' : 'Id',
                                'KeyType' : 'HASH'
                             },
                          ],
                          ProvisionedThroughput =
                          {
                               'ReadCapacityUnits' : 10,
                               'WriteCapacityUnits': 5
                          }
                        )
# Wait until the table exists.
table.meta.client.get_waiter('table_exists').wait(TableName= table_name )
print("Table {0} created successfully...".format(table_name))
table_name = 'Forum'
print("Creating table {0} ...".format(table_name))
table = dynamodb.create_table(TableName = table_name,
                              AttributeDefinitions=
                              [
                                  {
                                    'AttributeName' : 'Name',
                                    'AttributeType' : 'S'
                                  },
                              ],

                              KeySchema=
                              [
                                 {
                                  'AttributeName' : 'Name',
                                  'KeyType' : 'HASH'
                                 },
                              ],
                              ProvisionedThroughput=
                              {
                                'ReadCapacityUnits'    : 10,
                                'WriteCapacityUnits' : 5
                              }
                            )

# Wait until the table exists.
table.meta.client.get_waiter('table_exists').wait(TableName= table_name )

print("Table {0} created successfully...".format(table_name))

table_name = 'Thread'
print("Creating table {0}...".format(table_name))
table = dynamodb.create_table(TableName = table_name,
    AttributeDefinitions = [
        {
            'AttributeName' : 'ForumName',
            'AttributeType' : 'S'
        },
        {
            'AttributeName' : 'Subject',
            'AttributeType' : 'S'
        },
    ],
    KeySchema =[
        {
            'AttributeName' : 'ForumName',
            'KeyType' : 'HASH'
        },
        {
            'AttributeName' : 'Subject',
            'KeyType' : 'RANGE'
        }
    ],
    ProvisionedThroughput =
    {
        'ReadCapacityUnits'    : 10,
        'WriteCapacityUnits' : 5
    }
    )

table.meta.client.get_waiter('table_exists').wait(TableName= table_name )
print("Table {0} created successfully...".format(table_name))
table_name = 'Reply';
print("Creating table {0}...".format(table_name))
table = dynamodb.create_table(TableName = table_name,
    AttributeDefinitions =[
       {
            'AttributeName' : 'Id',
            'AttributeType' : 'S'
       },
       {
            'AttributeName' : 'ReplyDateTime',
            'AttributeType' : 'S'
       },
       {
            'AttributeName' : 'PostedBy',
            'AttributeType' : 'S'
       },
    ],
    LocalSecondaryIndexes =[
          {
            'IndexName' : 'PostedBy-index',
         'KeySchema' : [
                {
                    'AttributeName' : 'Id',
                    'KeyType' : 'HASH'
                },
                {
                    'AttributeName' : 'PostedBy',
                    'KeyType' : 'RANGE'
                 },
            ],
            'Projection' :{
                'ProjectionType' : 'KEYS_ONLY',
            },
        },
    ],
    KeySchema = [
        {
            'AttributeName' : 'Id',
            'KeyType' : 'HASH'
        },
        {
            'AttributeName' : 'ReplyDateTime',
            'KeyType' : 'RANGE'
        }
    ],
    ProvisionedThroughput ={
        'ReadCapacityUnits'    : 10,
        'WriteCapacityUnits' : 5
    }
)
table.meta.client.get_waiter('table_exists').wait(TableName= table_name )
print("Table {0} created successfully...".format(table_name))
