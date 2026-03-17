-- [[ HUNTER V7 - PRO TARGETING ]] --
local MIN = 50 
local URL = "http://localhost:3000/report"

-- (Tutaj zostaw funkcje send i cleanGraphics z poprzedniego kodu)

task.delay(10, function()
    print("--- [!] SZUKAM SERWERA Z ELITĄ... ---")
    
    local success, res = pcall(function()
        return game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100")).data
    end)

    if success and res then
        -- SORTOWANIE: Najpierw serwery z największą ilością graczy (ale nie pełne)
        table.sort(res, function(a, b)
            return a.playing > b.playing
        end)

        for _, v in pairs(res) do
            if v.playing < v.maxPlayers and v.playing > 5 and v.id ~= game.JobId then
                print("--- [!] SKOK NA SERWER: " .. v.playing .. " GRACZY ---")
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, v.id)
                task.wait(2)
                break
            end
        end
    end
    
    -- Jeśli nie udało się przeskoczyć w 15s, restartuj bota
    task.wait(5)
    game.Players.LocalPlayer:Kick("RESTART_FOR_PRO_SERVER")
end)
