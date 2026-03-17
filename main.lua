-- [[ UNIWERSALNY BRAINROT HUNTER (SYNAPSE & SOLAR) ]] --
local MIN_VALUE = 50 -- Szukaj powyżej 50M
local SERVER_URL = "http://localhost:3000/report"

print("Pomyślnie załadowano skrypt Huntera!")

-- Funkcja wysyłająca dane (wykrywa typ executora)
local function sendReport(data)
    local requestFunc = request or http_request or (syn and syn.request)
    if not requestFunc then 
        warn("Twój executor nie wspiera HTTP!") 
        return 
    end

    pcall(function()
        requestFunc({
            Url = SERVER_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = game:GetService("HttpService"):JSONEncode(data)
        })
    end)
end

-- Skanowanie graczy
local function scan()
    print("Skanowanie serwera...")
    local players = game:GetService("Players"):GetPlayers()
    for _, p in pairs(players) do
        if p ~= game.Players.LocalPlayer then
            local leaderstats = p:FindFirstChild("leaderstats")
            local brainrot = leaderstats and leaderstats:FindFirstChild("Brainrot")
            
            if brainrot and brainrot.Value >= (MIN_VALUE * 1000000) then
                local valueM = math.floor(brainrot.Value / 1000000)
                sendReport({
                    value = valueM,
                    jobId = game.JobId,
                    userName = p.Name,
                    botName = game.Players.LocalPlayer.Name
                })
            end
        end
    end
end

-- Server Hop (Zmiana serwera)
local function hop()
    print("Zmieniam serwer...")
    local success, res = pcall(function()
        return game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100"))
    end)
    
    if success and res and res.data then
        for _, s in pairs(res.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, s.id)
                return
            end
        end
    end
end

-- Główna pętla
task.spawn(function()
    -- Solar potrzebuje czasu na start, czekamy 5 sekund
    task.wait(5)
    
    -- Skanuj 3 razy co 7 sekund
    for i = 1, 3 do
        scan()
        task.wait(7)
    end
    
    -- Po skanowaniu zmień serwer
    hop()
end)
