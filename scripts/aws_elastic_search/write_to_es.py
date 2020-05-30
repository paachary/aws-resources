import json
import csv
import boto3
from elasticsearch import Elasticsearch, RequestsHttpConnection
from elasticsearch.helpers import bulk, streaming_bulk
from requests_aws4auth import AWS4Auth


ES_URL = "vpc-movies-3br6jppkeulox64eyaohgzzl7u.ap-south-1.es.amazonaws.com"
credentials = boto3.Session().get_credentials()

awsauth = AWS4Auth(
    credentials.access_key,
    credentials.secret_key,
    'ap-south-1',
    'es',
    session_token=credentials.token
)

es_client = Elasticsearch(
    hosts=[{'host': ES_URL, 'port': 443}],
    http_auth=awsauth,
    use_ssl=True,
    verify_certs=True,
    connection_class=RequestsHttpConnection
)


def write_into_es(filename):
    bulk(es_client, generate_es_doc(filename))


def generate_es_doc(filename):
    es_doc = {}
    with open(filename) as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=',')
        line_count = 0
        for row in csv_reader:
            if line_count == 0:
                line_count += 1
            else:
                es_doc['movie_id'] = row[0]
                es_doc['title'] = row[1]
                es_doc['genres'] = row[2] 
                line_count += 1
                
                yield {
                        "_index":"movies",
                        "_type":"document",
                        "doc":es_doc
                      }

if __name__ == "__main__":
        write_into_es("movies.csv")
