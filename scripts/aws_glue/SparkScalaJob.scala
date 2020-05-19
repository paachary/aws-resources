import com.amazonaws.services.glue.GlueContext
import com.amazonaws.services.glue.MappingSpec
import com.amazonaws.services.glue.errors.CallSite
import com.amazonaws.services.glue.util.GlueArgParser
import com.amazonaws.services.glue.util.Job
import com.amazonaws.services.glue.util.JsonOptions
import com.amazonaws.services.glue.DynamicFrame
import org.apache.spark.SparkContext
import org.apache.spark.sql.functions._
import scala.collection.JavaConverters._

object GlueApp {
  def main(sysArgs: Array[String]) {
    val sparkContext : SparkContext = new SparkContext()
    val glueContext: GlueContext = new GlueContext(sparkContext)
    // @params: [JOB_NAME]
    val args = GlueArgParser.getResolvedOptions(sysArgs, Seq("JOB_NAME").toArray)
    Job.init(args("JOB_NAME"), glueContext, args.asJava)
    // @type: DataSource
    // @args: [database = "movielens", table_name = "u_data", transformation_ctx = "datasource0"]
    // @return: datasource0
    // @inputs: []
    val moviesRatingDF = glueContext.getCatalogSource(database = "movielens", tableName = "u_data", redshiftTmpDir = "", transformationContext = "datasource0").getDynamicFrame().toDF()
    
    val moviesDF = glueContext.getCatalogSource(database = "movielens", tableName = "u_new_item", redshiftTmpDir = "", transformationContext = "datasource0").getDynamicFrame().toDF()
    
    val ratingsWithFilter = moviesRatingDF.
        selectExpr("movie_id as rating_movie_id", "rating").
        groupBy("rating_movie_id").
        agg(count("rating").alias("cnt"), avg("rating").alias("avg_rating")).
        where(" cnt > 10")
        
    val joinExpresession = ratingsWithFilter.col("rating_movie_id") === moviesDF.col("movie_id")
    
    val joinType = "inner"
    
    // apply the join and the filter condition
    // This sql provides us with the final result
    
    val finalOutputDF = ratingsWithFilter.select("rating_movie_id","avg_rating").
        join(moviesDF.selectExpr("movie_id", "title"), joinExpresession, joinType).
        selectExpr("rating_movie_id","title","avg_rating").
        orderBy(desc("avg_rating"))
        
    finalOutputDF.show(20,false)


    val finalOutputDynamicFrame = DynamicFrame(finalOutputDF, glueContext)


    // @type: ApplyMapping
    // @args: [mapping = [("user_id", "long", "user_id", "long"), ("movie_id", "long", "movie_id", "long"), ("rating", "long", "rating", "long"), ("rating_timestamp", "long", "rating_timestamp", "long")], transformation_ctx = "applymapping1"]
    // @return: applymapping1
    // @inputs: [frame = datasource0]
    val applymapping1 = finalOutputDynamicFrame.applyMapping(mappings = 
    Seq(("rating_movie_id", "long", "rating_movie_id", "long"), 
    ("title", "string", "title", "string"), 
    ("avg_rating", "double", "avg_rating", "double")), caseSensitive = false, transformationContext = "applymapping1")

    // @type: DataSink
    // @args: [connection_type = "s3", connection_options = {"path": "s3://bigdata-dataset/output/"}, format = "json", transformation_ctx = "datasink2"]
    // @return: datasink2
    // @inputs: [frame = applymapping1]
    val datasink2 = glueContext.getSinkWithFormat(connectionType = "s3", options = JsonOptions("""{"path": "s3://bigdata-dataset/output/"}"""), transformationContext = "datasink2", format = "json").writeDynamicFrame(applymapping1)
    Job.commit()
  }
}
