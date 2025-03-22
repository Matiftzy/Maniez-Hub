local jsonData = game:GetService("HttpService"):JSONEncode(data)

if request then
    request({
        Url = webhook,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = jsonData
    })
elseif http_request then
    http_request({
        Url = webhook,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = jsonData
    })
elseif syn and syn.request then
    syn.request({
        Url = webhook,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = jsonData
    })
else
    warn("[ERROR] No supported HTTP request function found.")
end
