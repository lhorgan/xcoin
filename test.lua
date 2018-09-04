local firstOutput = {value = 10000000, 
                     nonce = 8231996, 
                     data = {value = 1000, 
                             publicKey = "BLD6fw7+X/a2BBwYBEUOpwjNaSmpnnv9Jpj59iv4f7TIAQLOFR40Zg4Kh0fnoXRXqhYQGePJDSnWgaMl8uV8uCQ="}}

local lotherOutput = {value = 10000000, 
                     nonce = 8231996, 
                     data = {value = 1000, 
                             publicKey = "BLD6fw7+X/a2BBwYBEUOpwjNaSmpnnv9Jpj59iv4f7TIAQLOFR40Zg4Kh0fnoXRXqhYQGePJDSnWgaMl8uV8uCQ=",
                             contract = "*", love = "alice"}}

function firstOutputMatches(otherOutput)
    local allMatch = firstOutput["value"] == otherOutput["value"] and
                     firstOutput["nonce"] == otherOutput["nonce"] and
                     firstOutput["data"]["publicKey"] == otherOutput["data"]["publicKey"] and
                     firstOutput["data"]["value"] == otherOutput["data"]["value"]
    
    if allMatch then
        for key, _ in pairs(otherOutput) do
            if firstOutput[key] == nil then
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

print(firstOutputMatches(lotherOutput))