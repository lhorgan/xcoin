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

def wallet():
    with open("contract.lua") as contract_file:
        contract_code = contract_file.read()
    
    compiled_code = request("compilecontract", {"code": contract_code})["result"]

    # retrieve an output to spend
    utxos = request("listunspentoutputs", {"password": walletpassword, "account": walletaccount})["result"]["outputs"]
    xcoins = []
    for utxo in utxos:
        print(utxo)
        if utxo["data"]["contract"] == compiled_code:
            xcoins.append(utxo)
