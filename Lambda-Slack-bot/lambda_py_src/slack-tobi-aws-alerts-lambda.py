#!/usr/bin/python3.9
import urllib3
import json
import os


http = urllib3.PoolManager()
def lambda_handler(event, context):
    print(event)
    try:
        url = str(os.environ['webhookurl'])
        print(url)

        textToSendToSlack = "Test msg"
        print(textToSendToSlack)

        msg = {
            "channel": str(os.environ['channel']),
            "username": str(os.environ['username']),
            "text": textToSendToSlack,
            "icon_emoji": ""
        }
        
        encoded_msg = json.dumps(msg).encode('utf-8')
        resp = http.request('POST',url, body=encoded_msg)
        print({
            "message": textToSendToSlack,
            "status_code": resp.status,
            "response": resp.data
        })
        
    except Exception as e:
        print('Exception in lambda_slack.py.py - global')
        print(event)
        print(str(e))
        raise e
