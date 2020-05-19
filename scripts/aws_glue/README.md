
This script executes a scala job which reads from two tables, defined in the Glue Catalog, which is populated using Glue Crawler.

Detailed steps defined below:

Step1 : Setup Database under Glue

Step2 : Setup the Glue Crawler to scan the input s3 bucket (uploaded u.item, u.data and u.user files from movielens.com). 
        Note: Please ensure that the files do not contain any encoded characters as they cannot be processed by the given Spark compiler.

Step3 : Once tables are discovered by the crawler, review the tables' scehmas.

Step4 : Create a job using Spark with Scala (as this case) and have Glue create a job for you.

Step5 : Incase of manual debugging, you could create an AWS Glue Endpoint and initiate a spark-shell session with the Glue dependencies using the url provided in the endpoint page.

Step6 : Once the changes and implemented and tested, execute the Glue Job using the UI / CLI.


In case of job errors / success, the same will be displayed in the job results window pane.

The provided Scala script fetches data from the movielens data files uploaded into the source s3 bucket.
The output files are redirected to another folder in the same s3 bucket. The output can be redirected to any of the supported target sinks.

