-- [[ HUNTER V5 - NO-STALL VERSION ]] --
local MIN = 50 
local URL = "http://localhost:3000/report"

print("--- [!] SKRYPT STARTUJE (V5) ---")

-- Funkcja wysyłania z limitem czasu (timeout)
local function send(data)
    task.spawn(function()
        local req = request or http_request or (syn and syn.request)
        if req then
            -- Używamy pcall, żeby błąd sieci nie zatrzymał bota
            pcall(function() 
                req({
                    Url = URL,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = game:GetService("HttpService"):JSONEncode(data)
                })
            end)
        end
    end)
end

-- 1. Próba raportu do GUI (jeśli nie zadziała, bot idzie dalej)
send({type = "scan"})

-- 2. Skanowanie graczy
task.spawn(function()
    local players = game:GetService("Players"):GetPlayers()
    for _, p in pairs(players) do
        local ls = p:FindFirstChild("leaderstats")
        local br = ls and ls:FindFirstChild("Brainrot")
        if br and br.Value >= (MIN * 1000000) then
            print("--- [!] ZNALEZIONO CEL: " .. p.Name)
            send({
                type = "hit",
                value = math.floor(br.Value/1000000),
                jobId = game.JobId,
                userName = p.Name
            })
        end
    end
end)

-- 3. TOTALNIE WYMUSZONA ZMIANA SERWERA (Zegar startuje od razu)
print("--- [!] START ODTRZYMANIA DO ZMIANY (10s) ---")

task.delay(10, function()
    print("--- [!] CZAS MINĄŁ - WYMUSZAM ZMIANĘ ---")
    
    -- Próba 1: Teleportacja
    pcall(function()
        local s = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100")).data
        local target = s[math.random(1, #s)].id
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, target)
    end)

    -- Próba 2: Jeśli po 3 sekundach nadal tu jesteś -> KICK
    task.wait(3)
    game:GetService("Players").LocalPlayer:Kick("AUTO-HOP")
end)
