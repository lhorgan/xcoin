import requests
import json
import base64
import time
import sys
import random

url = "http://localhost:8383"
rpcuser = "ckrpc"
rpcpassword = "jxjQ9TgRqIyIlatz7a1TNjEJ2TNQ46M8K9WFEM9VXFQ="
walletpassword = "distance"
walletaccount = "nifty"
fee = 20000
publicKey = "BLD6fw7+X/a2BBwYBEUOpwjNaSmpnnv9Jpj59iv4f7TIAQLOFR40Zg4Kh0fnoXRXqhYQGePJDSnWgaMl8uV8uCQ="

def request(method, params):
    unencoded_str = rpcuser + ":" + rpcpassword
    encoded_str = base64.b64encode(unencoded_str.encode())
    headers = {
        "content-type": "application/json",
        "Authorization": "Basic " + encoded_str.decode('utf-8')}
    payload = {
        "method": method,
        "params": params,
        "jsonrpc": "2.0",
        "id": 0,
    }
    response = requests.post(url, data=json.dumps(payload), headers=headers).json()
    return response

def spend(outputId):
    input = {
        "outputId": outputId,
        "data": {
            "preimage": "Hello, World",
        },
    }

    # any arbitrary output to send the funds to. 
    # Replace the value with the desired amount that's
    # less than the input value
    newOutput = {
        "value": 50,
        "nonce": random.randint(1, 64000),
        "data": {"publicKey": publicKey},
    }

    transaction = {
        "inputs": [input], 
        "outputs": [newOutput], 
        "timestamp": int(time.time()),
    }
    print(json.dumps(transaction, sort_keys=True, indent=4))

    # broadcast the transaction on the network
    success = request("sendrawtransaction", {"transaction": transaction})["result"]
    print(success)

spend(sys.argv[1])