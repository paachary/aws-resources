package org.paachary.basicexample;

import com.amazonaws.regions.Regions;
import com.amazonaws.services.s3.AmazonS3EncryptionClientV2Builder;
import com.amazonaws.services.s3.AmazonS3EncryptionV2;
import com.amazonaws.services.s3.model.*;

import java.io.File;
import java.io.FileOutputStream;
import java.security.KeyPair;
import java.security.PrivateKey;
import java.security.PublicKey;

/**
 * Class to Decrypt the contents of an object in S3 bucket.
 * The user has to supply the public key which was used to encrypt the contents and the private key.
 * This keypair will be used to decrypt the contents and download the file locally.
 **/

public class S3ClientSideEnvelopDecryption {

    private static KeyPair generatePublicKeyPair(PublicKey publicKey,
                                                 PrivateKey privateKey) {
        return new KeyPair(publicKey, privateKey);
    }

    private static void downloadSecuredContentsToS3(String bucketName,
                                                    File publicKeyFile,
                                                    File privateKeyFile,
                                                    String s3ObjectKeyName) {
        GetKeys keys = new GetKeys();

        try {
            AmazonS3EncryptionV2 s3Encryption = AmazonS3EncryptionClientV2Builder.standard()
                    .withRegion(Regions.US_EAST_1)
                    .withCryptoConfiguration(new CryptoConfigurationV2().
                            withCryptoMode(CryptoMode.StrictAuthenticatedEncryption))
                    .withEncryptionMaterialsProvider(new StaticEncryptionMaterialsProvider(
                            new EncryptionMaterials(generatePublicKeyPair(keys.readPublicKey2(publicKeyFile),
                                    keys.readPrivateKey2(privateKeyFile)))))
                    .build();

            S3Object s3Object =  s3Encryption.getObject(bucketName, s3ObjectKeyName);
            S3ObjectInputStream s3is = s3Object.getObjectContent();
            FileOutputStream fos = new FileOutputStream(new File(s3ObjectKeyName));
            byte[] read_buf = new byte[1024];
            int read_len ;
            while ((read_len = s3is.read(read_buf)) > 0) {
                fos.write(read_buf, 0, read_len);
            }
            s3is.close();
            fos.close();

            s3Encryption.shutdown();
            System.out.println("Downloaded contents from bucket: "+ bucketName +
                    " to local file system onto the file "+ s3ObjectKeyName);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    public static void main(String[] args) {

        final String USAGE = "\n" +
                "To run this example, supply the name of an S3 bucket, the file to be downloaded," +
                "the public key and the private key file names which will be used to " +
                "decrypt the content of the object.\n" +
                "Ex: S3ClientSideEnvelopDecryption <bucket name> " +
                "<s3 Content File Name> " +
                "<Public Key Filename> " +
                "<Private Key Filename> \n";

        if (args.length < 4) {
            System.out.println(USAGE);
            System.exit(1);
        }

        String bucketName =  args[0];
        String s3ObjectKeyName = args[1];
        String publicFile = args[2];
        String privateFile =  args[3];

        AWSUtil.setAWSCredentials();

        downloadSecuredContentsToS3(bucketName,
                new File(publicFile),
                new File(privateFile),
                s3ObjectKeyName);
    }
}