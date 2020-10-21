package org.paachary.basicexample;

import com.amazonaws.AmazonClientException;
import com.amazonaws.auth.AWSCredentials;
import com.amazonaws.auth.EnvironmentVariableCredentialsProvider;

public interface AWSUtil {

    static AWSCredentials setAWSCredentials(){
        AWSCredentials credentials ;
        try {
            credentials = new EnvironmentVariableCredentialsProvider().getCredentials();
            System.out.println("Procured the credentials..");
        } catch (Exception e) {
            throw new AmazonClientException(
                    "Cannot load the credentials from the environment variables: AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY." +
                            "Please ensure the environment variables are setup properly.",
                    e);
        }
        return credentials;
    }
}

