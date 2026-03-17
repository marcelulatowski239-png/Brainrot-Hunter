-- [[ TURBO HUNTER V3 ]] --
local MIN = 50 
local URL = "http://localhost:3000/report"

print("--- SKRYPT STARTUJE ---")

local function send(data)
    pcall(function()
        local req = request or http_request or (syn and syn.request)
        if req then
            req({
                Url = URL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = game:GetService("HttpService"):JSONEncode(data)
            })
        end
    end)
end

-- Powiadom GUI o nowym serwerze
send({type = "scan"})

-- Skanowanie graczy (tylko raz, ale porządnie)
task.wait(1)
for _, p in pairs(game.Players:GetPlayers()) do
    local ls = p:FindFirstChild("leaderstats")
    local br = ls and ls:FindFirstChild("Brainrot")
    if br and br.Value >= (MIN * 1000000) then
        send({
            type = "hit",
            value = math.floor(br.Value/1000000),
            jobId = game.JobId,
            userName = p.Name
        })
    end
end

-- Błyskawiczna zmiana serwera (czekamy tylko 5 sekund łącznie)
task.wait(4)
local s = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100")).data
for _, v in pairs(s) do
    if v.playing < v.maxPlayers and v.id ~= game.JobId then
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, v.id)
        break
    end
end
