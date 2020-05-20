from pyspark import SparkContext

# Function to read ratings file in source S3 bucket and return a dataframe
def read_ratings_file( sc,\
                       source_path) :\
    return (sc.textFile("{0}/u.data".format(source_path)).\
        map(lambda f : f.split("\t")).\
        toDF().\
        selectExpr( "_1 AS user_id",
                    "_2 AS movie_id",\
                    "_3 AS rating",\
                    "_4 AS rating_timestamp"))

# Function to read movies file in source S3 bucket and return a dataframe
def read_movies_file(sc, source_path):\
    return (sc.textFile("{0}/u.item".format(source_path)).\
        map(lambda f : f.split("|")).\
        toDF().\
        selectExpr( "_1 AS movie_id",\
                    "_2 AS title",\
                    "_3 AS release_dt"))

# Function to read users file in source S3 bucket and return a dataframe
def read_users_file(sc):
    return (sc.textFile("(0)/u.user".format(source_path)).\
        map(lambda f : f.split("|")).\
        toDF().\
        selectExpr( "_1 AS user_id",\
                    "_2 AS age",\
                    "_3 AS gender",\
                    "_4 AS occupation",\
                    "_5 AS zip_code"))
