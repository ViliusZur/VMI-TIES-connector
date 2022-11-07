#!/bin/bash

# Input args
IN_FILE=$1
ID=$2
PRIVATE_KEY=$3
SENDER_ID=$4
TIES_CERT=$5

# Fixed received ID
RECEIVER_ID=188659752
OUT_DIR=./LithuanianTaxAuthority/MMR-SASK/files

# If any arg (except for ID that is optional) is missing, stop the execution
if [ -z "$IN_FILE" ] || [ -z "$PRIVATE_KEY" ] || [ -z "$SENDER_ID" ] || [ -z "$TIES_CERT" ]; then
  echo "USAGE:"
  echo -e "\tgenerate.sh IN_FILE [ID or \"\"] PRIVATE_KEY SENDER_ID TIES_CERT"
  exit 1
fi

# If the directory doesn't exists, create it
if [ ! -z "$OUT_DIR" ]; then
  mkdir -p $OUT_DIR
fi

# Split the file name by the . Test.xml -> [Test, xml]. Test.example.xml -> [Test, example, xml]
IFS='.' read -ra IN_FILE_PARTS <<< "$IN_FILE"

# Grab only the first part (be mindful if there are more than one dot)
FILE_NAME=${IN_FILE_PARTS[0]}

# Now we define a fixed filename that we will use later
FILE_NAME_CANONICALIZED=${FILE_NAME}_canonicalized

# Now we validate the input file against the TAX authority XSD schema
xmlstarlet val -s ./LithuanianTaxAuthority/MMR-SASK/$IN_FILE ./LithuanianTaxAuthority/MMR-SASK/MMR_SASK_v1.0.xsd

# Next step is cannonicalize according the c14n specification and save it
xmlstarlet c14n --exc-without-comments ./LithuanianTaxAuthority/MMR-SASK/$IN_FILE > $OUT_DIR/$FILE_NAME_CANONICALIZED.xml

# Here we wrap the cannonicalized filed around Object tags with an ID (if provided)
if [ -z "$ID" ]; then
  echo "<Object xmlns=\"http://www.w3.org/2000/09/xmldsig#\">$(cat $OUT_DIR/$FILE_NAME_CANONICALIZED.xml)</Object>" > $OUT_DIR/${FILE_NAME_CANONICALIZED}_object.xml
else
  echo "<Object xmlns=\"http://www.w3.org/2000/09/xmldsig#\" Id=\"$ID\">$(cat $OUT_DIR/$FILE_NAME_CANONICALIZED.xml)</Object>" > $OUT_DIR/${FILE_NAME_CANONICALIZED}_object.xml
fi

# Eventhough it may be not needed, we cannonicalize again the wrapped object 
xmlstarlet c14n --exc-without-comments $OUT_DIR/${FILE_NAME_CANONICALIZED}_object.xml > $OUT_DIR/$FILE_NAME_CANONICALIZED.xml

# We compute the SHA256 digest and split the output
IFS=' ' read -ra SHA256_PARTS <<< "$(openssl dgst -sha256 -r $OUT_DIR/$FILE_NAME_CANONICALIZED.xml)"

# The first part would be the digest itself
SHA256=${SHA256_PARTS[0]}

# Now we convert the sha from HEX to binary and then to base64 (required by TAX authority)
BASE64_SHA256="$(echo -n "$SHA256" | xxd -r -p | base64)"

# Generate the signature info block with the id (if provided) and the base64 encoded sha. This is, again, cannonicalized and saved
if [ -z "$ID" ]; then
  echo "<SignedInfo xmlns=\"http://www.w3.org/2000/09/xmldsig#\"><CanonicalizationMethod Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\"></CanonicalizationMethod><SignatureMethod Algorithm=\"http://www.w3.org/2001/04/xmldsig-more#rsa-sha256\"></SignatureMethod><Reference><Transforms><Transform Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\"></Transform></Transforms><DigestMethod Algorithm=\"http://www.w3.org/2001/04/xmlenc#sha256\"></DigestMethod><DigestValue>${BASE64_SHA256}</DigestValue></Reference></SignedInfo>" | xmlstarlet c14n - > $OUT_DIR/${FILE_NAME_CANONICALIZED}_sig.xml
else
  echo "<SignedInfo xmlns=\"http://www.w3.org/2000/09/xmldsig#\"><CanonicalizationMethod Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\"></CanonicalizationMethod><SignatureMethod Algorithm=\"http://www.w3.org/2001/04/xmldsig-more#rsa-sha256\"></SignatureMethod><Reference URI=\"#$ID\"><Transforms><Transform Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\"></Transform></Transforms><DigestMethod Algorithm=\"http://www.w3.org/2001/04/xmlenc#sha256\"></DigestMethod><DigestValue>${BASE64_SHA256}</DigestValue></Reference></SignedInfo>" | xmlstarlet c14n - > $OUT_DIR/${FILE_NAME_CANONICALIZED}_sig.xml
fi

# Now we encrypt the signature file with the private key and compute the base64 encoded signature
BASE64_SIGNATURE="$(openssl dgst -sha256 -sign $PRIVATE_KEY $OUT_DIR/${FILE_NAME_CANONICALIZED}_sig.xml | openssl enc -base64 -A)"

# Puth everything in a Signature block and concat the cannonicalized object file, remove the XML definition and save to the payload file
if [ -z "$ID" ]; then
  echo "<Signature xmlns=\"http://www.w3.org/2000/09/xmldsig#\"><SignedInfo><CanonicalizationMethod Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\"/><SignatureMethod Algorithm=\"http://www.w3.org/2001/04/xmldsig-more#rsa-sha256\"/><Reference><Transforms><Transform Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\"/></Transforms><DigestMethod Algorithm=\"http://www.w3.org/2001/04/xmlenc#sha256\"/><DigestValue>${BASE64_SHA256}</DigestValue></Reference></SignedInfo><SignatureValue>$BASE64_SIGNATURE</SignatureValue>$(cat $OUT_DIR/${FILE_NAME_CANONICALIZED}_object.xml | sed -e "s/<\?xml version=\"1\.0\" encoding=\"UTF-8\"\?>//")</Signature>" > $OUT_DIR/${SENDER_ID}_Payload.xml
else
  echo "<Signature xmlns=\"http://www.w3.org/2000/09/xmldsig#\"><SignedInfo><CanonicalizationMethod Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\"/><SignatureMethod Algorithm=\"http://www.w3.org/2001/04/xmldsig-more#rsa-sha256\"/><Reference URI=\"#$ID\"><Transforms><Transform Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\"/></Transforms><DigestMethod Algorithm=\"http://www.w3.org/2001/04/xmlenc#sha256\"/><DigestValue>${BASE64_SHA256}</DigestValue></Reference></SignedInfo><SignatureValue>$BASE64_SIGNATURE</SignatureValue>$(cat $OUT_DIR/${FILE_NAME_CANONICALIZED}_object.xml | sed -e "s/<\?xml version=\"1\.0\" encoding=\"UTF-8\"\?>//")</Signature>" > $OUT_DIR/${SENDER_ID}_Payload.xml
fi

# Put the XML definition at the very beginning of the Payload file
echo "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>$(cat $OUT_DIR/${SENDER_ID}_Payload.xml)" > $OUT_DIR/${SENDER_ID}_Payload.xml

# Zip the payload XML file
zip -j $OUT_DIR/${SENDER_ID}_Payload.zip $OUT_DIR/${SENDER_ID}_Payload.xml

# Generate two random HEX keys. One for the AES key and one for the Initialization Vector
AES_KEY=$(cat /dev/urandom | xxd -l 32 -c 32 -p | awk '{print toupper($0)}')
IV=$(cat /dev/urandom | xxd -l 16 -c 16 -p | awk '{print toupper($0)}')

# Use those keys for encrypting the zip with a cbc algorithm
openssl aes-256-cbc -p -nosalt -K $AES_KEY -iv $IV -in $OUT_DIR/${SENDER_ID}_Payload.zip -out $OUT_DIR/${SENDER_ID}_Payload

# Save the concatenated keys to a text file
echo -n "$AES_KEY$IV" > $OUT_DIR/aesKey.txt

# Convert the full string to binary and save to a bin file
cat $OUT_DIR/aesKey.txt | xxd -r -p > $OUT_DIR/aesKey.bin

# Print the size. Should always be 48 bytes, 32 of the AES key and 16 of the Initialization Vector
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  stat -c"AES KEY FILE SIZE BEFORE ENCRIPTION: %s bytes" $OUT_DIR/aesKey.bin
elif [[ "$OSTYPE" == "darwin"* ]]; then
  stat -f"AES KEY FILE SIZE BEFORE ENCRIPTION: %z bytes" $OUT_DIR/aesKey.bin
fi

# Sign with the TIES cert the bin file with the keys
openssl rsautl -encrypt -out $OUT_DIR/${RECEIVER_ID}_Key -certin -inkey $TIES_CERT -keyform DER -in $OUT_DIR/aesKey.bin

# Zip the encrypted payload and the signed key file and you're ready to go
DATE=""
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  DATE=$(date -u +%Y%m%dT%H%M%S%3NZ)
elif [[ "$OSTYPE" == "darwin"* ]]; then
  DATE=$(gdate -u +%Y%m%dT%H%M%S%3NZ)
fi

zip -j ./LithuanianTaxAuthority/MMR-SASK/${DATE}_$SENDER_ID.zip $OUT_DIR/${SENDER_ID}_Payload $OUT_DIR/${RECEIVER_ID}_Key

# Delete unnecessary files
rm -r $OUT_DIR
rm ./LithuanianTaxAuthority/MMR-SASK/$IN_FILE