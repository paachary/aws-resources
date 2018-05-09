"""
 Author     - Prashant Acharya
 Purpose    - This module reads data from a AWS Kinesis Stream
              and populates a database table
 Database   - Oracle
 Invocation - AWS Lambda
 Date       - 03/03/2018
"""
import cx_Oracle
import os
import logging
import ast
import base64
import db_config


# Initialize the logger
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# This is required to set the virtual host name (EC2 instance)
# on which the Lamdba function executes
with open('/tmp/HOSTALIASES', 'w') as hosts_file:
    hosts_file.write('{} localhost\n'.format(os.uname()[1]))


# Initialize the  SQL stmt to insert data into the table(s)
stmt = """ INSERT INTO security_price_dtls ( security_id, ticker_symb, load_dt, price)
            VALUES ({0}, '{1}', '{2}', {3})"""


# Making an AWS RDS Oracle database connection
conn_str = db_config.user+"/" + \
           db_config.passwd+"@" + \
           db_config.host+":" + \
           db_config.port+"/" + \
           db_config.db_name

# Initialize the connection object
conn = cx_Oracle.connect(conn_str)

# Initialize the cursor object
cursor = conn.cursor()

logger.info("Connected to the Oracle server")


def lambda_handler(event, context):

    # Connect to the kinesis stream
    logger.info('got event{}'.format(event))

    for record in event['Records']:

        # Kinesis data is base64 encoded so decode here
        payload = base64.b64decode(record["kinesis"]["data"])

        logger.info("Decoded payload: " + str(payload))

        # Decode to get the UTF format.
        # This is required to convert the input into a dictionary object
        payload_str = payload.decode("utf-8")

        # Convert the decoded string into a dictionary object
        payload_dict = ast.literal_eval(payload_str)

        logger.info("dict obj = {0}, {1}, {2}, {3}, {4}".format(
                        payload_dict,
                        payload_dict['SECURITY_ID'],
                        payload_dict['TICKER_SYMB'],
                        payload_dict['LOAD_DATE'],
                        payload_dict['PRICE']))

        cursor.execute(stmt.format(
                       payload_dict['SECURITY_ID'],
                       payload_dict['TICKER_SYMB'],
                       payload_dict['LOAD_DATE'],
                       payload_dict['PRICE']))
    conn.commit()
