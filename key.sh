pass=ibm-team
host=sandwood.org
keypass=ibm-team

rm root.jks
rm ca.jks
rm ibm-team-ssl.keystore
rm cert_req.csr
rm server.pem

keytool -genkeypair -keyalg RSA -keystore root.jks -storepass $pass -keypass $keypass -alias root -dname "cn=RootCA" -ext bc:c
keytool -genkeypair -keyalg RSA -keystore ca.jks -storepass $pass -keypass $keypass -dname "cn=ianCA" -alias ca -ext bc:c
keytool -genkeypair -keyalg RSA -keystore ibm-team-ssl.keystore -alias default -storepass $pass -keypass $keypass -dname "cn=$host"

keytool -keystore root.jks -storepass $pass -alias root -exportcert -rfc > root.pem

keytool -storepass $pass -keystore ca.jks -certreq -alias ca -file cert_req.csr

keytool -storepass $pass -keystore ca.jks -alias root -importcert -file root.pem -noprompt

keytool -storepass $pass -keystore root.jks -infile cert_req.csr -gencert -alias root -ext BC=0 -rfc > ca.pem

keytool -keystore ca.jks -storepass $pass -importcert -alias ca -file ca.pem

keytool -storepass $pass -keystore ibm-team-ssl.keystore -certreq -alias default | keytool -storepass $pass -keystore ca.jks -gencert -alias ca -ext ku:c=dig,keyEncipherment -rfc > server.pem

keytool -storepass $pass -keystore ibm-team-ssl.keystore -alias root -importcert -file root.pem -noprompt

keytool -storepass $pass -keystore ibm-team-ssl.keystore -alias ca -importcert -file ca.pem -noprompt

cat root.pem ca.pem server.pem | keytool -keystore ibm-team-ssl.keystore -storepass $pass -importcert -alias default

#cat server.pem | keytool -keystore server.jks -storepass $pass -importcert -alias server

#cp ibm-team-ssl.keystore /d/dev/ng60-2/jdtools/RJF-SERVER-I20160218-1956/server/liberty/servers/clm/resources/security/