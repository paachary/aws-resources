## Code Description : Python module to read csv file from S3 bucket and publish the messages to a SNS topic
## Author           : Prashant Acharya
## Date             : April 2018


import uuid
import csv
import json
import config
import setup_queues_topic


# initialize S3 client using the boto package
s3_client = setup_queues_topic.s3_client

# initialize SNS client using the boto package
sns_client = setup_queues_topic.sns_client

# publish the json message to the predefined sns topic
def publish_to_topic(topic_arn, message):
    response = sns_client.publish(
                        TopicArn         = topic_arn,
                        Message          = json.dumps({'default': json.dumps(message)}),
                        MessageStructure ='json'
                     )
    print(response)


# Populate a dictionary object for storing
# the Prices' details from the input CSV
def getPricesData(sec_id, ticker_symb, price, date):
    data = {}
    data['SECURITY_ID'] = sec_id
    data['TICKER_SYMB'] = ticker_symb
    data['PRICE'] = price
    data['LOAD_DATE'] = date
    return data


# Extract the details from the input CSV and get it in a JSON format
def extractCSV(csvfile):
    topic_arn = setup_queues_topic.get_topic_arn(topic_name=config.TOPIC)
    with open(csvfile) as sec_file:
        reader = csv.DictReader(sec_file, delimiter=',')
        for row in reader:
            data = json.dumps(getPricesData(row['Securityid'],
                                            row['Ticker'],
                                            row['Price'],
                                            row['Date']))

            # invoke the publish function
            publish_to_topic(topic_arn, message=data)


# Main lambda handler which gets triggered once a file is found in the S3 bucket
def handler(event, context):
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']

        download_path = '/tmp/{}{}'.format(uuid.uuid4(), key)

        s3_client.download_file(bucket, key, download_path)

        extractCSV(download_path)

