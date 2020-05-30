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
                appName("Top Movie Ratings").\
                getOrCreate()

    # Obtain the spark context
    sc = spark.sparkContext

    sc.setLogLevel("ERROR")

    # Read the ratings file from S3 and convert it into a Dataframe using SparkContext.rdd.toDF
    ratings_df = read_ratings_file(sc, source_path)
    
    # Read the movies file from S3 and convert it into a Dataframe using SparkContext.rdd.toDF
    movies_df = read_movies_file(sc, source_path)
  
    # Select the avg ratings of the movies which have been rated more than 10 times, to ignore false ratings
    ratings_with_filter = ratings_df.selectExpr("movie_id as rating_movie_id", "rating").\
                    groupBy("rating_movie_id").\
                    agg(count("rating").alias("cnt"), avg("rating").alias("avg_rating")).\
                    where(" cnt > 10")
    
    # Frame the join condition to get few attributes from the movies dataframe
    join_expresession = ratings_with_filter["rating_movie_id"] == movies_df["movie_id"]
    
    # the type of condition that we will be using to join movies and ratings on the movie_id attribute
    join_type = "inner"
    
    # Form the final dataframe which will serve as the output for top movie ratings
    final_output_df = ratings_with_filter.select("rating_movie_id","avg_rating").\
        join(movies_df.selectExpr("movie_id", "title"), join_expresession, join_type).\
        selectExpr("movie_id","title","avg_rating").\
        drop("rating_movie_id").\
        orderBy(desc("avg_rating"))
    
    # Generated the output of the final dataframe into a target bucket
    final_output_df.write.json("{0}/output/".format(dest_path))

    spark.stop()



def usage():
    print("Please pass the appropriate arguments to the program..\n")
    print("\t Usage >> \n")
    print("\t\t top_movie_ratings <source_path> <dest_path>\n\n")
    

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
