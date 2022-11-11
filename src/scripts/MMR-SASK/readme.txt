To run './generate' the folder must also contain:

ties_cert.der (public certificate from Lithuanian Tax Authority, not Rebellion's)
xml file to be packaged
Rebellion TIES private key (touch test_private_key7.key; nano test_private_key7.key; paste REBELLION_PRIVATE_KEY_STRING secret without \n's)
Get companyCode from Lithuanian Tax Authority portal

Command: ./generate.sh Test.xml 00000000001 test_private_key.key companyCode ties_cert.der