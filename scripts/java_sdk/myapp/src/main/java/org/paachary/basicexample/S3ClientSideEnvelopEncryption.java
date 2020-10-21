package org.paachary.basicexample;

import com.amazonaws.AmazonClientException;
import com.amazonaws.AmazonServiceException;
import com.amazonaws.auth.AWSCredentials;
import com.amazonaws.auth.AWSStaticCredentialsProvider;
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
import java.nio.file.Paths;
import java.security.KeyPair;
import java.security.PublicKey;

/**
 *
 *  Class to create a bucket and upload a file with contents encrypted using a user supplied public key.
 *  The public key itself is encrypted using the encryption material provided to the S3 encryption client.
 *
 *
 */
public class S3ClientSideEnvelopEncryption {
    final static String REGION = "us-east-1";

    private static void createS3Bucket(AWSCredentials credentials, String bucketName) {
        AmazonS3 s3 = AmazonS3ClientBuilder.standard()
                .withCredentials(new AWSStaticCredentialsProvider(credentials))
                .withRegion(REGION)
                .build();
        try {
            s3.createBucket(bucketName);
            System.out.println("Bucket : "+ bucketName +" created successfully.");
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

    private static KeyPair generatePublicKeyPair(PublicKey publicKey) {
        return new KeyPair(publicKey, null);
    }

    private static void uploadSecuredContentsToS3(String bucketName,
                                                  File publicKeyFile,
                                                  String s3ObjectKey,
                                                  String s3ObjectContent) {
        GetKeys keys = new GetKeys();

        try {
            AmazonS3EncryptionV2 s3Encryption = AmazonS3EncryptionClientV2Builder.standard()
                    .withRegion(Regions.US_EAST_1)
                    .withCryptoConfiguration(new CryptoConfigurationV2().
                            withCryptoMode(CryptoMode.StrictAuthenticatedEncryption))
                    .withEncryptionMaterialsProvider(new StaticEncryptionMaterialsProvider(
                            new EncryptionMaterials(generatePublicKeyPair(keys.readPublicKey2(publicKeyFile)))))
                    .build();

            s3Encryption.putObject(bucketName, s3ObjectKey, new File(s3ObjectContent));
            s3Encryption.shutdown();
            System.out.println("Uploaded contents to bucket: "+ bucketName);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void main(String[] args) {

        final String USAGE = "\n" +
                "To run this example, supply the name of an S3 bucket, " +
                "a file and the name of the public file to encrypt the object in the bucket, to\n" +
                "create the bucket and upload the file to it.\n" +
                "\n" +
                "Ex: S3ClientSideEnvelopEncryption <bucket name> <s3 Content File Name> <Public Key Filename> \n";

        if (args.length < 3) {
            System.out.println(USAGE);
            System.exit(1);
        }

        String bucketName = args[0];
        String s3ObjectContent = args[1];
        String s3ObjectKeyName = Paths.get(s3ObjectContent).getFileName().toString();
        String publicFile = args[2];

        createS3Bucket(AWSUtil.setAWSCredentials(), bucketName);

        uploadSecuredContentsToS3(bucketName,
                new File(publicFile),
                s3ObjectKeyName,
                s3ObjectContent);

    }
}
