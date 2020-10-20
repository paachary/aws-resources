package org.paachary.basicexample;

import java.util.UUID;

import com.amazonaws.AmazonClientException;
import com.amazonaws.AmazonServiceException;
import com.amazonaws.auth.AWSCredentials;
import com.amazonaws.auth.AWSStaticCredentialsProvider;
import com.amazonaws.auth.EnvironmentVariableCredentialsProvider;
import com.amazonaws.regions.Regions;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import com.amazonaws.services.s3.AmazonS3EncryptionClientV2Builder;
import com.amazonaws.services.s3.AmazonS3EncryptionV2;
import com.amazonaws.services.s3.model.*;

import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.NoSuchAlgorithmException;


public class S3ClientSideEncryption {
    public static void main(String[] args) throws NoSuchAlgorithmException {

        AWSCredentials credentials = null;
        try {
            credentials = new EnvironmentVariableCredentialsProvider().getCredentials();
            System.out.println(credentials);
        } catch (Exception e) {
            throw new AmazonClientException(
                    "Cannot load the credentials from the environment variables: AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY." +
                            "Please ensure the environment variables are setup properly.",
                    e);
        }


        AmazonS3 s3 = AmazonS3ClientBuilder.standard()
                .withCredentials(new AWSStaticCredentialsProvider(credentials))
                .withRegion("us-east-1")
                .build();

        String bucketName = "my-first-s3-bucket-" + UUID.randomUUID();
        String s3ObjectKey = "EncryptedContent2.txt";
        String s3ObjectContent = "This is the 2nd content to encrypt";

        System.out.println("===========================================");
        System.out.println("Getting Started with Amazon S3");
        System.out.println("===========================================\n");

        try {
            /*
             * Create a new S3 bucket - Amazon S3 bucket names are globally unique,
             * so once a bucket name has been taken by any user, you can't create
             * another bucket with that same name.
             *
             * You can optionally specify a location for your bucket if you want to
             * keep your data closer to your applications or users.
             */
            System.out.println("Creating bucket " + bucketName + "\n");
            s3.createBucket(bucketName);

            /*
             * List the buckets in your account
             */
            System.out.println("Listing buckets");
            for (Bucket bucket : s3.listBuckets()) {
                System.out.println(" - " + bucket.getName());
            }
            System.out.println();

            System.out.println("***Encrypting the contents to be loaded into the bucket****");

            KeyPairGenerator keyPairGenerator = KeyPairGenerator.getInstance("RSA");
            keyPairGenerator.initialize(2048);

            // generate an asymmetric key pair for testing
            KeyPair keyPair = keyPairGenerator.generateKeyPair();

            AmazonS3EncryptionV2 s3Encryption = AmazonS3EncryptionClientV2Builder.standard()
                    .withRegion(Regions.US_EAST_1)
                    .withCryptoConfiguration(new CryptoConfigurationV2().
                            withCryptoMode(CryptoMode.StrictAuthenticatedEncryption))
                    .withEncryptionMaterialsProvider(new StaticEncryptionMaterialsProvider(
                            new EncryptionMaterials(keyPair)))
                    .build();


            s3Encryption.putObject(bucketName, s3ObjectKey, s3ObjectContent);
            System.out.println(s3Encryption.getObjectAsString(bucketName, s3ObjectKey));
            s3Encryption.shutdown();

            System.out.println("****Listing objects****");
            ObjectListing objectListing = s3.listObjects(new ListObjectsRequest()
                    .withBucketName(bucketName)
                    .withPrefix("my"));
            for (S3ObjectSummary objectSummary : objectListing.getObjectSummaries()) {
                System.out.println(" - " + objectSummary.getKey() + "  " +
                        "(size = " + objectSummary.getSize() + ")");
            }
            System.out.println();

        }catch (AmazonServiceException ase) {
            System.out.println("Caught an AmazonServiceException, which means your request made it "
                    + "to Amazon S3, but was rejected with an error response for some reason.");
            System.out.println("Error Message:    " + ase.getMessage());
            System.out.println("HTTP Status Code: " + ase.getStatusCode());
            System.out.println("AWS Error Code:   " + ase.getErrorCode());
            System.out.println("Error Type:       " + ase.getErrorType());
            System.out.println("Request ID:       " + ase.getRequestId());
        } catch (AmazonClientException ace) {
            System.out.println("Caught an AmazonClientException, which means the client encountered "
                    + "a serious internal problem while trying to communicate with S3, "
                    + "such as not being able to access the network.");
            System.out.println("Error Message: " + ace.getMessage());
        }
    }
}