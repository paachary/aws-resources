from datetime import datetime, date, timedelta
import boto3
dynamodb = boto3.resource('dynamodb', 'ap-south-1')


def bulk_insert(table_name, items):
    table = dynamodb.Table(table_name)
    print("Adding data to the {} table...".format(table_name))
    with table.batch_writer() as batch:
        for item in items:
            batch.put_item(Item=item)

    print("Completed loading of data into the {} table...".format(table_name))


def populate_product_catalog_items():
    items = []

    Item = {
            'Id'              : 1101,
            'Title'           : 'Book 101 Title',
            'ISBN'            : '111-1111111111',
            'Authors'         : {'Author1'},
            'Price'           : '2',
            'Dimensions'      : '8.5 x 11.0 x 0.5',
            'PageCount'       : '500',
            'InPublication'   : '1',
            'ProductCategory' : 'Book'
    }

    items.append(Item)

    Item = {
            'Id'              : 102,
            'Title'           : 'Book 102 Title',
            'ISBN'            : '222-2222222222',
            'Authors'         : {'Author1', 'Author2'},
            'Price'           : '20',
            'Dimensions'      : '8.5 x 11.0 x 0.8',
            'PageCount'       : '600',
            'InPublication'   : '1',
            'ProductCategory' : 'Book'
            }
    items.append(Item)

    Item = {
            'Id'              : 103,
            'Title'           : 'Book 103 Title',
            'ISBN'            : '333-3333333333',
            'Authors'         : {'Author1', 'Author2'},
            'Price'           : '2000',
            'Dimensions'      : '8.5 x 11.0 x 1.5',
            'PageCount'       : '600',
            'InPublication'   : '0',
            'ProductCategory' : 'Book'
          }

    items.append(Item)

    Item = {

        'Id'              : 201,
        'Title'           : '18-Bike-201',
        'Description'     : '201 Description',
        'BicycleType'     : 'Road',
        'Brand'           : 'Mountain A',
        'Price'           : '100',
        'Gender'          : 'M',
        'Color'           : {'Red', 'Black'},
        'ProductCategory' : 'Bicycle'
    }

    items.append(Item)

    Item = {
            'Id'              : 202,
            'Title'           : '21-Bike-202',
            'Description'     : '202 Description',
            'BicycleType'     : 'Road',
            'Brand'           : 'Brand-Company A',
            'Price'           : '200',
            'Gender'          : 'M',
            'Color'           : {'Green', 'Black'},
            'ProductCategory' : 'Bicycle'
        }

    items.append(Item)

    Item = {
                'Id'              : 203,
                'Title'           : '19-Bike-203',
                'Description'     : '203 Description',
                'BicycleType'     : 'Road',
                'Brand'           : 'Brand-Company B',
                'Price'           : '300',
                'Gender'          : 'W',
                'Color'           : {'Red', 'Green', 'Black'},
                'ProductCategory' : 'Bicycle'
        }

    items.append(Item)

    Item = {
                'Id'              : 204,
                'Title'           : '18-Bike-204',
                'Description'     : '204 Description',
                'BicycleType'     : 'Mountain',
                'Brand'           : 'Brand-Company B',
                'Price'           : '400',
                'Gender'          : 'W',
                'Color'           : {'Red'},
                'ProductCategory' : 'Bicycle'
        }

    items.append(Item)

    Item = {
                'Id'              : 205,
                'Title'           : '20-Bike-205',
                'Description'     : '205 Description',
                'BicycleType'     : 'Hybrid',
                'Brand'           : 'Brand-Company C',
                'Price'           : '500',
                'Gender'          : 'B',
                'Color'           : {'Red', 'Black'},
                'ProductCategory' : 'Bicycle'
        }

    items.append(Item)

    return items


def populate_forum_table():
    items = []
    Item = {
            'Name'     : 'Amazon DynamoDB',
            'Category' : 'Amazon Web Services',
            'Threads'  : '0',
            'Messages' : '0',
            'Views'    : '1000'
    }

    items.append(Item)

    Item = {
            'Name'     : 'Amazon S3',
            'Category' : 'Amazon Web Services',
            'Threads'  : '0',
     }

    items.append(Item)
    return items


def populate_reply_table():
    oneDayAgo = date.today() - timedelta(days=1)

    sevenDaysAgo = date.today() - timedelta(days=7)

    fourteenDaysAgo = date.today() - timedelta(days=14)

    twentyOneDaysAgo = date.today() - timedelta(days=21)

    items = []

    Item = {
            'Id'            : 'Amazon DynamoDB#DynamoDB Thread 1',
            'ReplyDateTime' : fourteenDaysAgo.strftime('%Y/%m/%d'),
            'Message'       : 'DynamoDB Thread 1 Reply 2 text',
            'PostedBy'      : 'User B'
    }

    items.append(Item)

    Item = {
            'Id'            : 'Amazon DynamoDB#DynamoDB Thread 2',
            'ReplyDateTime' : twentyOneDaysAgo.strftime('%Y/%m/%d'),
            'Message'       : 'DynamoDB Thread 2 Reply 3 text',
            'PostedBy'      : 'User B'
    }

    items.append(Item)

    Item = {
            'Id'            : 'Amazon DynamoDB#DynamoDB Thread 2',
            'ReplyDateTime' : sevenDaysAgo.strftime('%Y/%m/%d'),
            'Message'       : 'DynamoDB Thread 2 Reply 2 text',
            'PostedBy'      : 'User A'
    }

    items.append(Item)

    Item = {
            'Id'            : 'Amazon DynamoDB#DynamoDB Thread 2',
            'ReplyDateTime' : oneDayAgo.strftime('%Y/%m/%d'),
            'Message'       : 'DynamoDB Thread 2 Reply 1 text',
            'PostedBy'      : 'User A'
    }

    items.append(Item)

    return items


if __name__ == "__main__":
    items = populate_product_catalog_items()
    bulk_insert(table_name="ProductCatalog", items=items)

    items = populate_forum_table()
    bulk_insert(table_name="Forum", items=items)

    items = populate_reply_table()
    bulk_insert(table_name="Reply", items=items)
