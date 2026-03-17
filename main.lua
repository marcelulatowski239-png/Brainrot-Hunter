-- [[ HUNTER V6 - LOW RAM EDITION ]] --
local MIN = 50 
local URL = "http://localhost:3000/report"

print("--- [!] TRYB LOW-RAM AKTYWNY ---")

-- FUNKCJA CZYSZCZENIA GRAFIKI (OSZCZĘDZA RAM)
local function cleanGraphics()
    local lighting = game:GetService("Lighting")
    lighting.GlobalShadows = false
    for _, v in pairs(lighting:GetChildren()) do
        if v:IsA("PostEffect") or v:IsA("Sky") then v:Destroy() end
    end
    settings().Rendering.QualityLevel = 1
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("Part") or v:IsA("MeshPart") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v:Destroy()
        end
    end
end

-- Odpal czyszczenie od razu
pcall(cleanGraphics)

local function send(data)
    task.spawn(function()
        local req = request or http_request or (syn and syn.request)
        if req then pcall(function() req({Url = URL, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = game:GetService("HttpService"):JSONEncode(data)}) end) end
    end)
end

send({type = "scan"})

task.spawn(function()
    task.wait(2)
    for _, p in pairs(game.Players:GetPlayers()) do
        local br = p:FindFirstChild("leaderstats") and p.leaderstats:FindFirstChild("Brainrot")
        if br and br.Value >= (MIN * 1000000) then
            send({type = "hit", value = math.floor(br.Value/1000000), jobId = game.JobId, userName = p.Name})
        end
    end
end)

-- Szybki Kick/Hop
task.delay(8, function()
    pcall(function()
        local s = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100")).data
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, s[math.random(1, #s)].id)
    end)
    task.wait(2)
    game.Players.LocalPlayer:Kick("AUTO-HOP")
end)
