local totalSupply = 1000
local firstNonce = 61
--[local output = Blockchain.getOutput(thisInput["outputId"])]

print("Contract running!!!")

function isFirstInChain(output)
    print("in is first in chain")
    local firstInChain = false
    local error = false

    --[ Is this the first output in the transaction? ]
    if output["data"]["contract"] == nil then
        print("abc")
        firstInChain = true
    else --[ So, the contract isn't null, then]
        print("def")
        local outputTransaction = Blockchain.getTransaction(output["creationTx"])
        for _, out in ipairs(outputTransaction["outputs"]) do
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

print("erm")
return verifyLegal()