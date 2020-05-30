import org.apache.spark.sql.{DataFrame, SparkSession}
import org.apache.spark.sql.functions._


class MovieDataSet{

  def getRatingsDataFrame(spark : SparkSession, inputFile : String) : DataFrame = {
    import spark.implicits._
    //"/home/hadoop/dataset/ml-100k/data/u.data"
    spark.read.format("text").load(inputFile).
      map{record =>
        val fields =
          record(0).toString.split("\\t")
        (fields(0).toInt,fields(1)toInt, fields(2).toDouble)
      }.
      withColumnRenamed("_1", "user_id").
      withColumnRenamed("_2","movie_id").
      withColumnRenamed("_3", "rating")
  }

  def getOnlyRatedMoviesGT10(spark : SparkSession, ratingsDataFrame : DataFrame) : DataFrame = {
    import spark.implicits._
    val movieWithRatingsGT10 = ratingsDataFrame.groupBy("movie_id").
      agg(count("movie_id").alias("movie_count")).
      filter("movie_count >= 10")

    val joinCondition = movieWithRatingsGT10("movie_id") === ratingsDataFrame("movie_id")
    val joinType = "inner"

    ratingsDataFrame.join(movieWithRatingsGT10, joinCondition, joinType).
      drop(movieWithRatingsGT10("movie_id")).drop(movieWithRatingsGT10("movie_count"))
  }

  def getUsersDataFrame(spark :SparkSession, fileName: String ) : DataFrame = {
    import spark.implicits._
    //"/home/hadoop/dataset/ml-100k/data/u.user"
    spark.read.format("text").load(fileName).
      map{record =>

        val fields = record(0).toString.split("\\|")
        (fields(0).toInt,fields(1)toInt, fields(2),fields(3),fields(4))
      }.
      withColumnRenamed("_1", "user_id").
      withColumnRenamed("_2","age").
      withColumnRenamed("_3", "gender").
      withColumnRenamed("_4", "occupation").
      withColumnRenamed("_5","zip_code")
  }

  def getMoviesDataFrame(spark :SparkSession, fileName: String ) : DataFrame = {
    import spark.implicits._
    //"/home/hadoop/dataset/ml-100k/data/u.item"
    spark.read.format("text").load(fileName).
      map{record =>
        val fields =
          record(0).toString.split("\\|")
        (fields(0).toInt,fields(1), fields(2))
      }.
      withColumnRenamed("_1", "movie_id").
      withColumnRenamed("_2","title").
      withColumnRenamed("_3", "release_dt")
  }

  def getMoviesGenreDataFrame(spark :SparkSession, fileName: String ) : DataFrame = {
    import spark.implicits._
    //"/home/hadoop/dataset/ml-100k/data/u.item"
    spark.read.format("text").load(fileName).
      map { record =>
        val fields =
          record(0).toString.split("\\|")
        (fields(0).toInt, fields(5), fields(6), fields(7),
          fields(8), fields(9), fields(10), fields(11), fields(12), fields(13),
          fields(14), fields(15), fields(16), fields(17), fields(18), fields(19),
          fields(20), fields(21), fields(22), fields(23)
        )
      }.
      withColumnRenamed("_1", "movie_id").
      withColumnRenamed("_2", "UNKNOWN").
      withColumnRenamed("_3", "ACTION").
      withColumnRenamed("_4", "ADVENTURE").
      withColumnRenamed("_5", "ANIMATION").
      withColumnRenamed("_6", "CHILDREN").
      withColumnRenamed("_7", "COMEDY").
      withColumnRenamed("_8", "CRIME").
      withColumnRenamed("_9", "DOCUMENTARY").
      withColumnRenamed("_10", "DRAMA").
      withColumnRenamed("_11", "FANTASY").
      withColumnRenamed("_12", "FILM_NOIR").
      withColumnRenamed("_13", "HORROR").
      withColumnRenamed("_14", "MUSICAL").
      withColumnRenamed("_15", "MYSTERY").
      withColumnRenamed("_16", "ROMANCE").
      withColumnRenamed("_17", "SCI_FI").
      withColumnRenamed("_18", "THRILLER").
      withColumnRenamed("_19", "WAR").
      withColumnRenamed("_20", "WESTERN").
      select($"movie_id"
        , expr("stack(19,'UNKNOWN',unknown," +
          " 'ACTION',action," +
          " 'ADVENTURE', ADVENTURE," +
          " 'CHILDREN', CHILDREN," +
          " 'COMEDY', COMEDY," +
          " 'CRIME', CRIME," +
          " 'DOCUMENTARY', DOCUMENTARY," +
          " 'DRAMA', DRAMA," +
          " 'ANIMATION', ANIMATION," +
          " 'FANTASY', FANTASY," +
          " 'FILM_NOIR', FILM_NOIR," +
          " 'HORROR', HORROR," +
          " 'MUSICAL', MUSICAL," +
          " 'MYSTERY', MYSTERY," +
          " 'ROMANCE', ROMANCE," +
          " 'SCI_FI', SCI_FI," +
          " 'THRILLER', THRILLER," +
          " 'WAR', WAR," +
          " 'WESTERN', WESTERN " +
          ") as (genre, total) ")
      ).filter("total != 0").drop("f")
  }

  def getUserPreferencesDataFrame(
                                moviesDataFrame               : DataFrame,
                                movieGenreDataFrame           : DataFrame,
                                usersDataFrame                : DataFrame,
                                filteredMovieRatingsDataframe : DataFrame
                                ) : DataFrame = {

    val join_condition_1 = moviesDataFrame("movie_id") === movieGenreDataFrame("movie_id")
    val join_type_1 = "inner"

    val completeMovieDF = moviesDataFrame.join(movieGenreDataFrame, join_condition_1, join_type_1).
      drop(movieGenreDataFrame("movie_id"))

    val join_condition_2 = completeMovieDF("movie_id") === filteredMovieRatingsDataframe("movie_id")
    val join_type_2= "inner"

    val fullMoviesListDF = completeMovieDF.join(filteredMovieRatingsDataframe, join_condition_2, join_type_2)      drop(filteredMovieRatingsDataframe("movie_id"))

    val join_condition_3 = fullMoviesListDF("user_id") === usersDataFrame("user_id")
    val join_type3 = "inner"

    usersDataFrame.join(fullMoviesListDF, join_condition_3, join_type3).
      drop(fullMoviesListDF("user_id"))
  }
}

object MovieDataSet {

  def main(args: Array[String]) : Unit = {
    if (args.length != 2) {
      println("Insufficient arguments passed to the program:")
      println("\t Usage :")
      println("\t MovieDataSet <input file directory> <output directory>\n\n")
    } else {
      val inputFileDir = args(0)
      val outputDir = args(1)

      val spark = SparkSession.builder().appName("MovieLensDataSet").getOrCreate()
      spark.sparkContext.setLogLevel("ERROR")
      val movieDataSet = new MovieDataSet
      val moviesDF = movieDataSet.getMoviesDataFrame(spark, inputFileDir+"/u.item")
      val moviesGenreDF = movieDataSet.getMoviesGenreDataFrame(spark, inputFileDir+"/u.item")
      val usersDF = movieDataSet.getUsersDataFrame(spark, inputFileDir+"/u.user")
      val ratingsDF = movieDataSet.getRatingsDataFrame(spark, inputFileDir+"/u.data")
      val onlyRatedMovieGT10 = movieDataSet.getOnlyRatedMoviesGT10(spark, ratingsDF)
      val movieDataFrame = movieDataSet.getUserPreferencesDataFrame(moviesDF,moviesGenreDF,
        usersDF, onlyRatedMovieGT10)
      movieDataFrame.write.parquet(outputDir+"/parquet")
      movieDataFrame.write.json(outputDir+"/json")
      spark.close()
    }
  }
}
