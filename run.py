# 94a74988db7f6ab4cbbeb8bf43ed52ca4565c0df1a72408ee94e047acf0af83e
# 9ae2c2b5155065e2cc557534596fd1cb379c15e27cd94ef3c9bf9f04bf8ff994

import requests
import json
import base64
import time
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

def make_contract():
    contractCode = "print(\"running Lua contract!\")\r\nreturn true"

    # compile the contract source code
    compiledCode = request("compilecontract", {"code": contractCode})["result"]

    # retrieve an output to spend
    toSpend = request("listunspentoutputs", {"password": walletpassword, "account": walletaccount})["result"]["outputs"][0]

    # input wrapper spending output  
    input = {"outputId": toSpend["id"]}

    # new output for spent funds (minus fee)
    newOutput = {"value": toSpend["value"] - fee,
                "nonce": random.randint(1, 64000),
                "data": {"contract": compiledCode}}

    outputId = request("calculateoutputid", {"output": newOutput})["result"]
    print(outputId)

    # the unsigned transaction
    transaction = {
        "inputs": [input], 
        "outputs": [newOutput], 
        "timestamp": int(time.time()),
    }
    #print(json.dumps(transaction, sort_keys=True, indent=4))

    # have ckd sign the unsigned transaction for us
    signed = request("signtransaction", {"transaction": transaction, "password": walletpassword})["result"]
    #print(json.dumps(signed, sort_keys=True, indent=4))

    # broadcast the signed transaction on the network
    success = request("sendrawtransaction", {"transaction": signed})["result"]
    print(success)

    return signed

make_contract()