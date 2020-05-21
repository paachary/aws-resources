import common_functions
import pyspark
from pyspark.sql import SparkSession
from pyspark import SparkContext
# This import is needed to use the SQL Functions from the dataframes
from pyspark.sql.functions import * 
from common_functions import *


# Method to initiate the processing
def init(source_path, dest_path):
    
    # Initialize the Spark Session
    spark = SparkSession.\
                builder.\
                appName("Movie Stats based on Occupation and Movie Genres").\
                getOrCreate()

    # Obtain the spark context
    sc = spark.sparkContext

    sc.setLogLevel("ERROR")

    # Read the ratings file from S3 and convert it into a Dataframe using SparkContext.rdd.toDF
    ratings_df = read_ratings_file(sc, source_path)
    
    # Read the movies file from S3 and convert it into a Dataframe using SparkContext.rdd.toDF
    movies_df = read_movies_file(sc, source_path)
    
    # Read the users file from S3 and convert it into a Dataframe using SparkContext.rdd.toDF
    users_df = read_users_file(sc, source_path)
    
    
    # Construct the movies file into a rating_genres Dataframe using SparkContext.rdd.toDF
    ratings_genres_df = read_movie_genres(sc, source_path)
    
    user_ratings_df = ratings_df.selectExpr("movie_id as rating_movie_id", "user_id AS rating_user_id", "rating")

    join_expresession_movie = user_ratings_df["rating_movie_id"] == ratings_genres_df["movie_id"]

    join_expresession_user = user_ratings_df["rating_user_id"] == users_df["user_id"]

    join_type = "inner"

     # Construct the join between ratings and rating_genres dataframes
    final_output_df = user_ratings_df.\
    join(ratings_genres_df,join_expresession_movie,join_type).\
    join(users_df,join_expresession_user,join_type).\
    groupBy("occupation","genre").\
    agg(count("movie_id").alias("movie_count")).\
    orderBy(desc("movie_count"))
    
    # Generated the output of the final dataframe into a target bucket
    final_output_df.write.json("{0}/output/".format(dest_path))

    spark.stop()



def usage():
    print("Please pass the appropriate arguments to the program..\n")
    print("\t Usage >> \n")
    print("\t\t movie_count_by_occupation_and_genres <source_path> <dest_path>\n\n")
    

def main():
    
    import sys

    if (len(sys.argv) != 3):
        usage()
    else:
        source_path = sys.argv[1].strip()
        dest_path   = sys.argv[2].strip()
        
        if source_path is None or source_path == "":
            usage()
        
        if dest_path is None or dest_path == "":
            usage()
            

        init(source_path, 
             dest_path)


if __name__ == "__main__":
    main()
