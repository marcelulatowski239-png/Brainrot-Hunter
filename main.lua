-- [[ BRAINROT HUNTER V2 - TURBO MODE ]] --
local MIN_VALUE = 50 
local URL = "http://localhost:3000/report"

local function send(data)
    local f = request or http_request or (syn and syn.request)
    if f then pcall(function() f({Url = URL, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = game:GetService("HttpService"):JSONEncode(data)}) end) end
end

-- Sygnał wejścia (licznik w GUI)
send({type = "scan"})

local function check()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer then
            local br = p:FindFirstChild("leaderstats") and p.leaderstats:FindFirstChild("Brainrot")
            if br and br.Value >= (MIN_VALUE * 1000000) then
                send({
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
    -- Czekamy tylko 2 sekundy na załadowanie leaderstats
    task.wait(2)
    
    -- Szybkie skanowanie: 3 razy co 3 sekundy (łącznie tylko 9-10 sekund na serwerze)
    for i = 1, 3 do 
        check() 
        task.wait(3) 
    end
    
    -- BŁYSKAWICZNY SERVER HOP
    local success, res = pcall(function()
        return game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100"))
    end)
    
    if success and res and res.data then
        -- Sortujemy serwery, żeby wybierać te z największą ilością osób (większa szansa na hit)
        table.sort(res.data, function(a, b) return a.playing > b.playing end)
        
        for _, s in pairs(res.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, s.id)
                break
            end
        end
    end
end)
