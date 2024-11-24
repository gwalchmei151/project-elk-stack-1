# Troubleshooting
This section will document all the random issues that crop up and the steps taken to mitigate them

## Failed to authenticate user 'elastic' against https://192.168.126.10:9200/_security/_authenticate?pretty

![](/assets/Troubleshooting/AuthenticationFailure/trouble-setup-pass-failure-1.png)

There are a few things I can try - I have tried resetting the password before in a former iteration of this project. This time I think we will regenerate the keystore first.

- remove old keystore and generate new one
```bash
sudo rm /etc/elasticsearch/elasticsearch.keystore
sudo /usr/share/elasticsearch/bin/elasticsearch-keystore create
```
- Re-attempt setup passwords - get these error messages instead
```bash
org.elasticsearch.ElasticsearchSecurityException: failed to load SSL configuration [xpack.security.transport.ssl] - cannot read configured [PKCS12] keystore (as a truststore) [/etc/elasticsearch/certs/transport.p12] - this is usually caused by an incorrect password; (no password was provided)
	at org.elasticsearch.xpack.core.ssl.SSLService.lambda$loadSslConfigurations$11(SSLService.java:620)
	at java.base/java.util.HashMap.forEach(HashMap.java:1430)
	at java.base/java.util.Collections$UnmodifiableMap.forEach(Collections.java:1708)
	at org.elasticsearch.xpack.core.ssl.SSLService.loadSslConfigurations(SSLService.java:616)
	at org.elasticsearch.xpack.core.ssl.SSLService.<init>(SSLService.java:160)
	at org.elasticsearch.xpack.core.ssl.SSLService.<init>(SSLService.java:147)
	at org.elasticsearch.xpack.core.security.CommandLineHttpClient.execute(CommandLineHttpClient.java:149)
	at org.elasticsearch.xpack.core.security.CommandLineHttpClient.execute(CommandLineHttpClient.java:112)
	at org.elasticsearch.xpack.security.authc.esnative.tool.SetupPasswordTool$SetupCommand.checkElasticKeystorePasswordValid(SetupPasswordTool.java:340)
	at org.elasticsearch.xpack.security.authc.esnative.tool.SetupPasswordTool$InteractiveSetup.execute(SetupPasswordTool.java:203)
	at org.elasticsearch.common.cli.EnvironmentAwareCommand.execute(EnvironmentAwareCommand.java:55)
	at org.elasticsearch.cli.Command.mainWithoutErrorHandling(Command.java:95)
	at org.elasticsearch.cli.MultiCommand.execute(MultiCommand.java:95)
	at org.elasticsearch.cli.Command.mainWithoutErrorHandling(Command.java:95)
	at org.elasticsearch.cli.Command.main(Command.java:52)
	at org.elasticsearch.launcher.CliToolLauncher.main(CliToolLauncher.java:65)
Caused by: org.elasticsearch.common.ssl.SslConfigException: cannot read configured [PKCS12] keystore (as a truststore) [/etc/elasticsearch/certs/transport.p12] - this is usually caused by an incorrect password; (no password was provided)
	at org.elasticsearch.common.ssl.SslFileUtil.ioException(SslFileUtil.java:57)
	at org.elasticsearch.common.ssl.StoreTrustConfig.readKeyStore(StoreTrustConfig.java:99)
	at org.elasticsearch.common.ssl.StoreTrustConfig.createTrustManager(StoreTrustConfig.java:83)
	at org.elasticsearch.xpack.core.ssl.SSLService.createSslContext(SSLService.java:479)
	at java.base/java.util.HashMap.computeIfAbsent(HashMap.java:1229)
	at org.elasticsearch.xpack.core.ssl.SSLService.lambda$loadSslConfigurations$11(SSLService.java:618)
	... 15 more
Caused by: java.io.IOException: keystore password was incorrect
	at java.base/sun.security.pkcs12.PKCS12KeyStore.engineLoad(PKCS12KeyStore.java:2112)
	at java.base/sun.security.util.KeyStoreDelegator.engineLoad(KeyStoreDelegator.java:228)
	at java.base/java.security.KeyStore.load(KeyStore.java:1499)
	at org.elasticsearch.common.ssl.KeyStoreUtil.readKeyStore(KeyStoreUtil.java:73)
	at org.elasticsearch.common.ssl.StoreTrustConfig.readKeyStore(StoreTrustConfig.java:95)
	... 19 more
Caused by: java.security.UnrecoverableKeyException: failed to decrypt safe contents entry: javax.crypto.BadPaddingException: Given final block not properly padded. Such issues can arise if a bad key is used during decryption.
	... 24 more
```

- But we aren't given the passwords to any of those files at creation
- The password we have is correct
    ![](/assets/Troubleshooting/AuthenticationFailure/test-pw-curl-1.png)
- [cat /var/log/elasticsearch/elasticsearch.log](./troubleshoot-journalctl-elastic-20241124-0437.log)
- We notice a few things from the error message
    - `org.elasticsearch.ElasticsearchSecurityException: failed to load SSL configuration [xpack.security.transport.ssl] `
    - `Caused by: org.elasticsearch.common.ssl.SslConfigException: cannot read configured [PKCS12] keystore (as a truststore) [/etc/elasticsearch/certs/transport.p12] - this is usually caused by an incorrect password; (no password was provided)`
    - `Caused by: java.io.IOException: keystore password was incorrect`
    - `Caused by: java.security.UnrecoverableKeyException: failed to decrypt safe contents entry: javax.crypto.BadPaddingException: Given final block not properly padded. Such issues can arise if a bad key is used during decryption.`
- It looks like we will need to generate new p12 files and the keystore and everything else first
    1. `su -` to become root user
    2. cd into the certs directory - /etc/elasticsearch/certs/
    3. Regenerate the CA certificate
        `sudo /usr/share/elasticsearch/bin/elasticsearch-certutil ca --out /etc/elasticsearch/certs/ca.p12 --pass ""`
    4. Generate new transport.p12
        `sudo /usr/share/elasticsearch/bin/elasticsearch-certutil cert --ca /etc/elasticsearch/certs/ca.p12 --out /etc/elasticsearch/certs/transport.p12`
        - Used password "12345"
    5. Generate new http.p12
        `sudo /usr/share/elasticsearch/bin/elasticsearch-certutil cert --ca /etc/elasticsearch/certs/ca.p12 --out /etc/elasticsearch/certs/http.p12`
        - Used password "12345"
    6. Restart service - still get errors
        - Recreating the keystore does not work
    7. We need to also add the password to the keystore
        `sudo /usr/share/elasticsearch/bin/elasticsearch-keystore add xpack.security.transport.ssl.keystore.secure_password`
    8. Update the elastisearch.yml file
    9. Realise that the permissions of the new files could be causing issues
    ![](/assets/Troubleshooting/AuthenticationFailure/ls-la-certs-permissions.png)
    10. Change ownership
        `sudo chown elasticsearch:elasticsearch /etc/elasticsearch/certs/*`
    11. Set correct permissions
        `sudo chmod 640 /etc/elasticsearch/certs/*`
    12. Update yml file to have absolute file path and restart service
        ![](/assets/Troubleshooting/AuthenticationFailure/elastic-yml-certs-absolute-file-path.png)
    13. We get AccessDeniedException errors in the new [log](./troubleshoot-journalctl-elastic-20241124-0557.log)
    14. Reset ownership and permissions for directory and files
        ```bash
        sudo chown -R elasticsearch:elasticsearch /etc/elasticsearch/certs
        sudo chmod 750 /etc/elasticsearch/certs
        sudo chmod 640 /etc/elasticsearch/certs/*
        ```
    15. Verify password for transport.p12 