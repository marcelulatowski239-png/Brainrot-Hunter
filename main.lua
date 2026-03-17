-- [[ HUNTER V4 - STABLE & FAST ]] --
local MIN = 50 
local URL = "http://localhost:3000/report"

print("--- [!] SKRYPT URUCHOMIONY ---")

-- Funkcja wysyłania (bezpieczna)
local function send(data)
    task.spawn(function()
        local req = request or http_request or (syn and syn.request)
        if req then
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

-- 1. Zwiększ licznik w GUI od razu
send({type = "scan"})

-- 2. Skanowanie graczy (w tle)
task.spawn(function()
    print("--- [!] SKANOWANIE... ---")
    local players = game:GetService("Players"):GetPlayers()
    for _, p in pairs(players) do
        if p ~= game.Players.LocalPlayer then
            local br = p:FindFirstChild("leaderstats") and p.leaderstats:FindFirstChild("Brainrot")
            if br and br.Value >= (MIN * 1000000) then
                print("--- [!] ZNALEZIONO: " .. p.Name)
                send({
                    type = "hit",
                    value = math.floor(br.Value/1000000),
                    jobId = game.JobId,
                    userName = p.Name
                })
            end
        end
    end
end)

-- 3. Server Hop po 7 sekundach (NIEZALEŻNY)
task.wait(7)
print("--- [!] ZMIANA SERWERA... ---")

local function hop()
    local s = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100")).data
    for _, v in pairs(s) do
        if v.playing < v.maxPlayers and v.id ~= game.JobId then
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, v.id)
            return
        end
    end
end

-- Jeśli teleportacja zawiedzie, wyrzuć bota (RAM go połączy ponownie)
task.spawn(function()
    pcall(hop)
    task.wait(5)
    game.Players.LocalPlayer:Kick("Szukanie nowego serwera...")
end)
