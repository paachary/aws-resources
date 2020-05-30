from pyspark import SparkContext
from pyspark.sql.functions import col , expr

# Function to read ratings file in source S3 bucket and return a dataframe
def read_ratings_file( sc,\
                       source_path) :\
    return (sc.textFile("{}/u.data".format(source_path)).\
        map(lambda f : f.split("\t")).\
        toDF().\
        selectExpr( "_1 AS user_id",
                    "_2 AS movie_id",\
                    "_3 AS rating",\
                    "_4 AS rating_timestamp"))

# Function to read movies file in source S3 bucket and return a dataframe
def read_movies_file(sc, source_path):\
    return (sc.textFile("{}/u.item".format(source_path)).\
        map(lambda f : f.split("|")).\
        toDF().\
        selectExpr( "_1 AS movie_id",\
                    "_2 AS title",\
                    "_3 AS release_dt"))

# Function to read users file in source S3 bucket and return a dataframe
def read_users_file(sc, source_path):
    return (sc.textFile("{}/u.user".format(source_path)).\
        map(lambda f : f.split("|")).\
        toDF().\
        selectExpr( "_1 AS user_id",\
                    "_2 AS age",\
                    "_3 AS gender",\
                    "_4 AS occupation",\
                    "_5 AS zip_code"))

def read_movie_genres(sc, source_path):
    return (sc.textFile("{}/u.item".format(source_path)).\
            map(lambda f : f.split("|")).\
            toDF().\
            selectExpr( "_1 AS movie_id",\
                  "_6 AS  UNKNOWN", \
                  "_7 AS  ACTION", \
                  "_8 AS  ADVENTURE",\
                  "_9 AS  ANIMATION", \
                  "_10 AS CHILDREN",\
                  "_11 AS COMEDY", \
                  "_12 AS CRIME" , \
                  "_13 AS DOCUMENTARY", \
                  "_14 AS DRAMA", \
                  "_15 AS FANTASY",\
                  "_16 AS FILM_NOIR", \
                  "_17 AS HORROR",\
                  "_18 AS MUSICAL", \
                  "_19 AS MYSTERY",\
                  "_20 AS ROMANCE",\
                  "_21 AS SCI_FI",\
                  "_22 AS THRILLER",\
                  "_23 AS WAR",\
                  "_24 AS WESTERN").\
            select(col("movie_id"), expr("stack(19,\
            'UNKNOWN', UNKNOWN,\
            'ACTION', ACTION,\
            'ADVENTURE', ADVENTURE,\
            'CHILDREN', CHILDREN,\
            'COMEDY', COMEDY,\
            'CRIME', CRIME,\
            'DOCUMENTARY', DOCUMENTARY,\
            'DRAMA', DRAMA,\
            'ANIMATION', ANIMATION,\
            'FANTASY', FANTASY,\
            'FILM_NOIR', FILM_NOIR,\
            'HORROR', HORROR,\
            'MUSICAL', MUSICAL,\
            'MYSTERY', MYSTERY,\
            'ROMANCE', ROMANCE,\
            'SCI_FI', SCI_FI,\
            'THRILLER', THRILLER,\
            'WAR', WAR,\
            'WESTERN', WESTERN ) as (genre, total)")).\
            filter("total != 0").drop("total"))
