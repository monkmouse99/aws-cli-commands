# encrypt a file (Linux / Mac)
aws kms encrypt \
    --key-id aafdf495-60be-4dbc-a231-dba98724722d \
    --plaintext fileb://my-plaintext-file \
    --output text \
    --query CiphertextBlob | base64 \
    --decode > my-encrypted-file

# encrypt a file (Windows)
aws kms encrypt \
    --key-id aafdf495-60be-4dbc-a231-dba98724722d \
    --plaintext fileb://my-plaintext-file \
    --output text \
    --query CiphertextBlob > C:\Temp\my-encrypted-file.base64

certutil -decode C:\Temp\my-encrypted-file.base64 C:\Temp\my-encrypted-file

# decrypt a file (Linux / Mac)
aws kms decrypt \
    --ciphertext-blob fileb://my-encrypted-file \
    --output text \
    --query Plaintext | base64 --decode > my-decrypted-file

# decrypt a file (Windows)
aws kms decrypt \
    --ciphertext-blob fileb://my-encrypted-file \
    --output text \
    --query Plaintext > my-decrypted-file.base64

certutil -decode my-decrypted-file.base64 my-decrypted-file
