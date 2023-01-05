# aws ssm get-parameters
aws ssm get-parameters --names /dynamodb/table1
# return encrypted values
aws ssm get-parameters --names encrypted-parameter --with-decryption
# return by path
aws ssm get-parameters-by-path --path /dynamodb