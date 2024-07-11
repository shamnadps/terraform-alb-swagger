def lambda_handler(event, context):
    response = {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'text/plain'  # Adjust content type as needed
        },
        'body': 'Hello from Lambda for Python!'
    }
    return response
