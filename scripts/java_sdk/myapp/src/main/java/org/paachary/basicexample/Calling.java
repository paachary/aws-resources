package org.paachary.basicexample;

import java.io.File;
import java.io.IOException;

public class Calling {

    public static void main(String[] args) throws Exception {

        File file = new File("/home/hadoop/keyPairs/rsa.public");

        GetKeys keys = new GetKeys();

        try {
            System.out.println(keys.readPublicKey2(file));
        } catch (IOException e) {
            e.printStackTrace();
        }
        try {
            file = new File("/home/hadoop/keyPairs/private.key");
            System.out.println(keys.readPrivateKey2(file));
        } catch (Exception e) {
            e.printStackTrace();
        }

    }
}
