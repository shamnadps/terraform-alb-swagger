def lambda_handler(event, context):
    message = event['body']['message']
    response = {
        "statusCode": 200,
        "body": {
            "response": f"Received: {message}"
        }
    }
    return response
