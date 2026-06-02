import boto3

s3 = boto3.client('s3') 
response = s3.get_object(Bucket='my-app-bucket', Key='config.json')