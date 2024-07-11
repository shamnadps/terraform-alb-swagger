import json

def lambda_handler(event, context):
    # Extract request body
    body = json.loads(event['body'])

    # Extract firstName and lastName from request body
    firstName = body.get('firstName', '')
    lastName = body.get('lastName', '')

    # Concatenate firstName and lastName
    fullName = firstName + ' ' + lastName

    # Prepare response
    response = {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json'
        },
        'body': json.dumps({'name': fullName})
    }

    return response
