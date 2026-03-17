-- [[ HUNTER V2 - ULTIMATE ]] --
local MIN_VALUE = 50 
local URL = "http://localhost:3000/report"

local function req(data)
    local f = request or http_request or (syn and syn.request)
    if f then pcall(function() f({Url = URL, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = game:GetService("HttpService"):JSONEncode(data)}) end) end
end

-- Powiedz GUI, że bot wszedł na serwer
req({type = "scan"})

local function check()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer then
            local br = p:FindFirstChild("leaderstats") and p.leaderstats:FindFirstChild("Brainrot")
            if br and br.Value >= (MIN_VALUE * 1000000) then
                req({
                    type = "hit",
                    value = math.floor(br.Value/1000000),
                    jobId = game.JobId,
                    userName = p.Name
                })
            end
        end
    end
end

task.spawn(function()
    for i = 1, 4 do check() task.wait(5) end
    -- Server Hop
    local s = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100")).data
    for _, v in pairs(s) do
        if v.playing < v.maxPlayers and v.id ~= game.JobId then
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, v.id)
            break
        end
    end
end)
