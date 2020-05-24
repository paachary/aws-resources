import json
import boto3
import time
from elasticsearch import Elasticsearch, RequestsHttpConnection
from requests_aws4auth import AWS4Auth


s3 = boto3.client('s3')
sts = boto3.client('sts')

ES_URL = os.environ["ES_URL"]

credentials = boto3.Session().get_credentials()

es_client = Elasticsearch(
    hosts=[{'host': ES_URL, 'port': 443}], 
    http_auth=awsauth, 
    use_ssl=True, 
    verify_certs=True, 
    connection_class=RequestsHttpConnection
)

def record_order(id, doc):
    """Post an order to the ES Cluster index"""
    es_client.index(
        index="movielens", 
        doc_type="occupation_n_movie_genres", 
        body=doc,
        id=id
    )


def lambda_handler(event, context):
    for record in event['Records']:
        es_doc = {}
        print(event)
        if record['eventName'] == 'INSERT':
            occupation = record['dynamodb']['NewImage']['occupation']['S']
            genre = record['dynamodb']['NewImage']['genre']['S']
            movie_count = record['dynamodb']['NewImage']['movie_count']['N']
            id = occupation+":"+genre
            es_doc['occupation'] = occupation
            es_doc['genre'] = genre
            es_doc['movie_count'] = movie_count
            if ES_URL == "":
                print('Empty string')
                print(id+":"+es_doc)
            else: 
                print('elseing it up')
                print(es_doc)
                record_order(id, json.dumps(es_doc))
            time.sleep(1)
        else:
            pass
