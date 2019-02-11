import uuid
import csv
import json
import boto3

dynamodb = boto3.resource('dynamodb', region_name='ap-south-1')

table = dynamodb.Table('Movies')


# Initialize the S3 client
s3_client = boto3.client('s3')

# Extract the details from the input CSV and get it in a JSON format
def extractCSV(csvfile):
    with open(csvfile) as movie_file:
        reader = csv.DictReader(movie_file, delimiter=',')
        for row in reader:
            movie_id = row['movieId']
            title = row['title']
            genres = row['genres']

            table.put_item(
               Item={
                   'MovieId': movie_id,
                   'Title': title,
                   'Genres': genres,
                }
            )

# Main handler function invoked from the AWS Lambda Service
def handler(event, context):
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']

        download_path = '/tmp/{}{}'.format(uuid.uuid4(), key)

        s3_client.download_file(bucket, key, download_path)

        extractCSV(download_path)



