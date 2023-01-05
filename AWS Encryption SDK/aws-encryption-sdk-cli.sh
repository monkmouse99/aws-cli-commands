# install AWS encryption SDK
pip install aws-encryption-sdk-cli --user
# upgrade the AWS encryption SDK
pip install --upgrade aws-encryption-sdk-cli --user
# create environment variable for KMS key ARN
cmkArn=arn:aws:kms:ap-southeast-2:515148227241:key/38a49b53-75c1-4924-9de2-0367ffd8d517
# create file named encryption-sdk.txt before next command
# encrypt file called encryption-sdk.txt
aws-encryption-cli --encrypt --input encryption-sdk.txt --master-keys key=$cmkArn --metadata-output ~/metadata --encryption-context purpose=test --output .
# decrypt data
aws-encryption-cli --decrypt --input encryption-sdk.txt.encrypted --metadata-output ~/metadata --encryption-context purpose=test --output .