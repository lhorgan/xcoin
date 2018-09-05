local totalSupply = 1000
local thisOutput = Blockchain.getOutput(thisInput["outputId"])
local firstOutput = {value = 10000000, 
                     nonce = 82319964, 
                     data = {value = 1000, 
                             publicKey = "BLD6fw7+X/a2BBwYBEUOpwjNaSmpnnv9Jpj59iv4f7TIAQLOFR40Zg4Kh0fnoXRXqhYQGePJDSnWgaMl8uV8uCQ=",
                             contract = "*"}}

function getInputOutputsToOutput(output)
    local outputTransaction = Blockchain.getTransaction(output["creationTx"])
    local transactionInputs = outputTransaction["inputs"]
    local outputs = {}
    for _, inpId in ipairs(transactionInputs) do
        local inp = Blockchain.getInput(inpId)
        local out = Blockchain.getOutput(inp["outputId"])
        table.insert(outputs, out)
    end
    return outputs
end
 
function isFirstInChain(output)
    local isFirst = false
    inputOutputs = getInputOutputsToOutput(output)
    for _, out in ipairs(inputOutputs) do
        if out["data"]["contract"] == nil then
            isFirst = true
            break
        elseif out["data"]["contract"] ~= thisOutput["data"]["contract"] then
            isFirst = true
            break
        end
    end

    return isFirst
end

function getTotalInputValue()
    local totalInputValue = 0
    for _, inp in ipairs(thisTransaction["inputs"]) do
        out = Blockchain.getOutput(inp["outputId"])
        outVal = out["data"]["value"]
        if isValidSpendAmount(outVal) then
            totalInputValue = totalInputValue + outVal
        else
            print("Invalid spend value ", outVal)
            return -1
        end
    end
    print("Total input value: ", totalInputValue)
    return totalInputValue
end

function getTotalOutputValue()
    local totalOutputValue = 0
    for _, out in ipairs(thisTransaction["outputs"]) do
        inpVal = out["data"]["value"]
        if isValidSpendAmount(inpVal) then
            totalOutputValue = totalOutputValue + inpVal
        else
            print("Invalid spend value ", totalOutputValue)
            return -1
        end
    end
    print("Total output value: ", totalOutputValue)
    return totalOutputValue
end

function isValidSpendAmount(val)
    if type(val) ~= "number" then
        print("Spend must be a number")
        return false
    elseif math.floor(val) ~= val then
        print("Spend must be integral")
        return false
    elseif val < 1 then -- also, guards against negative spends
        print("Must send at least 1 Xcoin")
        return false
    end

    return true
end

function verifyLegal()
    if not verifySpender() then
        print("Spender is not authorized for these funds.")
        return false
    end

    if not verifyContractPropagated() then
        print("Contract not propagated!")
        return false
    end

    local output = Blockchain.getOutput(thisInput["outputId"])

    local firstInChain = isFirstInChain(output) 
    if firstInChain then
        print("This is the first transaction in the chain.")
        if not firstOutputMatches(output) then
            print("The specified output doesn't match the required first output.")
            return false
        else 
            totalOutputValue = getTotalOutputValue()
            if (totalOutputValue == -1) or (totalOutputValue ~= totalSupply) then -- don't really need that first check, but why not?
                print("Exactly the total value must be spent in the first transaction.")
                return false
            end
        end
    else --[ not the first in the chain ] 
        totalInputValue = getTotalInputValue()
        totalOutputValue = getTotalOutputValue()
        if (totalInputValue == -1) or (totalOutputValue == -1) or (totalInputValue ~= totalOutputValue) then
            print("You have to spend exactly what you put in!")
            return false
        end
    end
    
    print("Looks like everything checks out.")

    return true
end

function firstOutputMatches(otherOutput)
    local allMatch = firstOutput["value"] == otherOutput["value"] and
                     firstOutput["nonce"] == otherOutput["nonce"] and
                     firstOutput["data"]["publicKey"] == otherOutput["data"]["publicKey"] and
                     firstOutput["data"]["value"] == otherOutput["data"]["value"]
    
    if allMatch then
        for key, _ in pairs(otherOutput) do
            if key ~= "id" and key ~= "creationTx" and firstOutput[key] == nil then
                print("Unknown key ", key)
                allMatch = false
                break
            end  
        end

        if allMatch then
            for key, _ in pairs(otherOutput["data"]) do
                if firstOutput["data"][key] == nil then
                    print("Unknown key in data field ", key)
                    allMatch = false
                    break
                end
            end
        end
    end

    return allMatch
end

function verifyContractPropagated()
    for _, out in ipairs(thisTransaction["outputs"]) do
        --contract propagation
        --note that sometimes we might need to include actual k320, in which case there won't be an xcoin contract, but they're just to fund the transaction
        --(this is why we need the first clause in the if statement below)
        if (out["data"]["value"] ~= nil) and (out["data"]["contract"] ~= thisOutput["data"]["contract"]) then
            return false
        end
    end

    return true
end

function verifySpender()
    -- retrieve the output this input is spending
    local output = Blockchain.getOutput(thisInput["outputId"])

    -- create a new instance of the Crypto class
    local crypto = Crypto.new()

    -- set the public key of the class instance to the public key
    -- specified in the output being spent
    crypto:setPublicKey(output["data"]["publicKey"])

    -- return true if the given signature is valid
    print("thisInput[outputId]", thisInput["outputId"])
    print("outputSetId", outputSetId)
    print("thisInput['data']['signature']", thisInput["data"]["signature"])
    return crypto:verify(thisInput["outputId"] .. outputSetId, thisInput["data"]["signature"])
end

return verifyLegal()