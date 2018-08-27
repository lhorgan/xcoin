local output = Blockchain.getOutput(thisInput["outputId"])

print("Contract running!!!")

--[ Is this the first output in the transaction? ]
if output["data"]["contract"] == nil then
    --[  ]
end

return true