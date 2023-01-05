import boto3

ssm = boto3.client('ssm', region_name="ap-southeast-2")

def lambda_handler(event, context):
    parameter = ssm.get_parameter(Name='/dynamodb/table1', WithDecryption=True)
    print(parameter['Parameter']['Value'])
    return "Successfully retrieved parameter!"