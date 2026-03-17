-- [[ TURBO HUNTER V4 - AGGRESSIVE HOP ]] --
local MIN = 50 
local URL = "http://localhost:3000/report"
local TS = game:GetService("TeleportService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

print("--- [HUNTER DEBUG]: SKRYPT STARTUJE ---")

local function send(data)
    pcall(function()
        local req = request or http_request or (syn and syn.request)
        if req then
            req({
                Url = URL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(data)
            })
        end
    end)
end

-- 1. Powiedz GUI, że bot jest na serwerze
send({type = "scan"})

-- 2. Skanowanie graczy
print("--- [HUNTER DEBUG]: SKANOWANIE... ---")
task.wait(2)
for _, p in pairs(Players:GetPlayers()) do
    local ls = p:FindFirstChild("leaderstats")
    local br = ls and ls:FindFirstChild("Brainrot")
    if br and br.Value >= (MIN * 1000000) then
        print("--- [HUNTER DEBUG]: ZNALEZIONO CEL: " .. p.Name)
        send({
            type = "hit",
            value = math.floor(br.Value/1000000),
            jobId = game.JobId,
            userName = p.Name
        })
    end
end

-- 3. Wymuszona zmiana serwera
print("--- [HUNTER DEBUG]: SZUKANIE NOWEGO SERWERA... ---")
task.wait(1)

local function doHop()
    local success, res = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100")).data
    end)

    if success and res then
        for _, v in pairs(res) do
            if v.playing < v.maxPlayers and v.id ~= game.JobId then
                print("--- [HUNTER DEBUG]: TELEPORTACJA DO: " .. v.id)
                -- Próba teleportacji
                TS:TeleportToPlaceInstance(game.PlaceId, v.id, Players.LocalPlayer)
                
                -- Jeśli po 5 sekundach nadal tu jesteś, spróbuj ponownie z innym serwerem
                task.delay(5, function()
                    if game.JobId == v.id then return end -- Udało się
                    print("--- [HUNTER DEBUG]: RETRY HOP... ---")
                end)
            end
        end
    else
        print("--- [HUNTER DEBUG]: BŁĄD POBIERANIA LISTY SERWERÓW ---")
    end
end

-- Odpal teleportację
doHop()

-- Zabezpieczenie: Jeśli nic nie zadziała przez 10 sekund, po prostu wyjdź (crash bota do ponownego odpalenia)
task.wait(15)
if #Players:GetPlayers() > 0 then
    print("--- [HUNTER DEBUG]: TOTALNY ZWIESZ - RESTARTUJĘ ---")
    -- Niektóre executory wymagają rkick() lub po prostu wywalenia gracza
    Players.LocalPlayer:Kick("Changing Server...")
end
