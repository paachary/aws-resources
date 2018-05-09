"""
 Author     - Prashant Acharya
 Purpose    - This module reads data from a CSV file on a S3 bucket
              and populates an AWS Kinesis Stream
 Invocation - AWS Lambda
 Date       - 03/03/2018
"""

import uuid
import csv
import json
import boto3
from boto import kinesis

# Initialize the Kinesis Stream object
kinesis = kinesis.connect_to_region("ap-south-1")

# Initialize the S3 client
s3_client = boto3.client('s3')


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
    with open(csvfile) as sec_file:
        reader = csv.DictReader(sec_file, delimiter=',')
        for row in reader:
            data = json.dumps(getPricesData(row['Securityid'],
                                            row['Ticker'],
                                            row['Price'],
                                            row['Date']))
            kinesis.put_record("SecurityStream", data, "partitionkey")
            print(data)


# Main handler function invoked from the AWS Lambda Service
def handler(event, context):
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']

        download_path = '/tmp/{}{}'.format(uuid.uuid4(), key)

        s3_client.download_file(bucket, key, download_path)

        extractCSV(download_path)
