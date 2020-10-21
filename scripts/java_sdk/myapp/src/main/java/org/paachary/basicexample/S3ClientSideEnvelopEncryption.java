package org.paachary.basicexample;

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
import com.amazonaws.services.s3.model.CryptoConfigurationV2;
import com.amazonaws.services.s3.model.CryptoMode;
import com.amazonaws.services.s3.model.EncryptionMaterials;
import com.amazonaws.services.s3.model.StaticEncryptionMaterialsProvider;

import java.io.File;
import java.io.IOException;
import java.util.UUID;

public class S3ClientSideEnvelopEncryption {
    final String REGION = "us-east-1";
    final String BUCKET_NAME = "my-first-s3-bucket-" + UUID.randomUUID();

    private AWSCredentials setAWSCredentials(){
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
        return credentials;
    }

    private void createS3Bucket(AWSCredentials credentials) {
        AmazonS3 s3 = AmazonS3ClientBuilder.standard()
                .withCredentials(new AWSStaticCredentialsProvider(credentials))
                .withRegion(REGION)
                .build();

        try {
            s3.createBucket(BUCKET_NAME);
        } catch (AmazonServiceException ase) {
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

    private void uploadSecuredContentsToS3(File publicKeyFile) {
        GetKeys keys = new GetKeys();

        try {
            keys.readPublicKey2(publicKeyFile);
            AmazonS3EncryptionV2 s3Encryption = AmazonS3EncryptionClientV2Builder.standard()
                    .withRegion(Regions.US_EAST_1)
                    .withCryptoConfiguration(new CryptoConfigurationV2().
                            withCryptoMode(CryptoMode.StrictAuthenticatedEncryption))
                    .withEncryptionMaterialsProvider(new StaticEncryptionMaterialsProvider(
                            new EncryptionMaterials(keyPair)))
                    .build();


        } catch (IOException e) {
            e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
