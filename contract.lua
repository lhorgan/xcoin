local totalSupply = 1000
local firstNonce = 61
--[local output = Blockchain.getOutput(thisInput["outputId"])]

print("Contract running!!!")

function getInputOutputsToOutput(output)
    print("HELLO WORLD GET INPUT OUTPUTS TO OUTPUT")
    local outputTransaction = Blockchain.getTransaction(output["creationTx"])
    print("FANTASTIC")
    local transactionInputs = outputTransaction["inputs"]
    print("ALL GOOD")
    local outputs = {}
    print("ALIVE")
    print(inspect(transactionInputs))
    for _, inpId in ipairs(transactionInputs) do
        local inp = Blockchain.getInput(inpId)
        local out = Blockchain.getOutput(inp["outputId"])
        table.insert(outputs, out)
    end

    print("here goes...")
    print(inspect(outputs))
    return outputs
end

function inspect(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. inspect(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end
 

function isFirstInChain(output)
    print("in is first in chain")
    local firstInChain = false
    local error = false

    print("here is the output that got passed in...")
    print(output)

    --[ Is this the first output in the transaction? ]
    if output["data"]["contract"] == nil then
        print("abc")
        firstInChain = true
    else --[ So, the contract isn't null, then]
        print("def")
        local outputTransaction = Blockchain.getTransaction(output["creationTx"])
        print("Here is the output transaction")
        print(outputTransaction)
        for _, outId in ipairs(outputTransaction["outputs"]) do
            print("HERE IS OUT ID")
            print(outId)
            out = Blockchain.getOutput(outId)
            print(out)
            if out["data"]["contract"] ~= output["data"]["contract"] then
                firstInChain = true
                break
            else
                print("At least one of the inputs contains the contract, and at least one does not.  This is prohibited.")
                error = true
            end
        end
    end

    print("ghi")
    return error, firstInChain
end

function getTotalInputValue()
    local totalInputValue = 0
    for _, inp in ipairs(thisTransaction["inputs"]) do
        out = Blockchain.getOutput(inp["outputId"])
        totalInputValue = totalInputValue + out["data"]["value"]
    end
end

function getTotalOutputValue()
    local totalOutputValue = 0
    for _, out in ipairs(thisTransaction["outputs"]) do
        totalOutputValue = totalInputValue + out["data"]["value"]
    end
    return totalOutputValue
end

function verifyLegal()
    print("Verifying legal....")
    local output = Blockchain.getOutput(thisInput["outputId"])

    local error, firstInChain = isFirstInChain(output) 
    if error then
        return false
    elseif firstInChain then
        if output["nonce"] ~= firstNonce then
            print("Nonce for first payment is incorrect.")
            return false
        end
    else --[ not the first in the chain ] 
        --[ look at each input in this transaction and make sure that none of ITS inputs are themselves first ]
        for _, inp in ipairs(thisTransaction["inputs"]) do
            out = Blockchain.getOutput(inp["outputId"])
            if isFirstInChain(out) then
                if output["nonce"] ~= firstNonce then
                    print("The payment tries to use funds that simply don't exist.  This is prohibited.")
                    return false
                end
            end
        end
    end
    
    return true
end

getInputOutputsToOutput(Blockchain.getOutput(thisInput["outputId"]))
return false