--[[
    RYS Hub — Player Radar Panel v5.0
    
    Features:
    1. UI ดึงข้อมูลผู้เล่นทั้งหมด
    2. ฟังก์ชัน Spectate ส่องมุมกล้อง
    3. ฟังก์ชัน Teleport ไปหาคนนั้น
--]]

return function(RYS, ConnMgr)
    local PlayerList = {}
    
    local Players = RYS.Services.Players
    local Workspace = RYS.Services.Workspace
    
    local isSpectating = false
    local currentSpectateTarget = nil
    local originalCameraSubject = nil

    function PlayerList.Spectate(player)
        local camera = Workspace.CurrentCamera
        if not camera then return end
        
        -- ถ้ากดคนเดิม (เลิก Spectate)
        if isSpectating and currentSpectateTarget == player then
            PlayerList.StopSpectate()
            return
        end
        
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then
            -- เก็บค่ากล้องเดิมไว้ก่อนสลับ (ถ้ายังไม่เคยเก็บ)
            if not isSpectating then
                originalCameraSubject = camera.CameraSubject
            end
            
            camera.CameraSubject = char.Humanoid
            isSpectating = true
            currentSpectateTarget = player
            RYS.Notify("Spectate", "กำลังส่องมุมกล้องของ " .. player.DisplayName, 2)
        else
            RYS.Notify("Spectate Error", "ผู้เล่นยังไม่ได้เกิด", 2)
        end
    end

    function PlayerList.StopSpectate()
        if isSpectating then
            local camera = Workspace.CurrentCamera
            if camera and originalCameraSubject then
                camera.CameraSubject = originalCameraSubject
            end
            isSpectating = false
            currentSpectateTarget = nil
            RYS.Notify("Spectate", "กลับมุมกล้องปกติ", 2)
        end
    end
    
    function PlayerList.IsSpectating(player)
        return isSpectating and currentSpectateTarget == player
    end

    function PlayerList.TeleportToPlayer(player)
        local targetChar = player.Character
        if not targetChar or not targetChar:FindFirstChild("HumanoidRootPart") then
            RYS.Notify("Teleport Error", "ผู้เล่นยังไม่ได้เกิด", 2)
            return false
        end
        
        local rootPart = RYS.GetRootPart()
        if rootPart then
            -- วาร์ปไปด้านหลังเป้าหมายเล็กน้อย (3 stud)
            rootPart.CFrame = targetChar.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
            RYS.Notify("Teleport", "วาร์ปไปหา " .. player.DisplayName, 2)
            return true
        end
        return false
    end

    function PlayerList.GetPlayersData()
        local data = {}
        local localPlr = Players.LocalPlayer
        
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= localPlr then
                local dist = 0
                local hp = 0
                local maxHp = 100
                
                if p.Character then
                    local hum = p.Character:FindFirstChild("Humanoid")
                    if hum then
                        hp = math.floor(hum.Health)
                        maxHp = math.floor(hum.MaxHealth)
                    end
                    
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    local myHrp = RYS.GetRootPart()
                    if hrp and myHrp then
                        dist = math.floor((hrp.Position - myHrp.Position).Magnitude)
                    end
                end
                
                table.insert(data, {
                    Player = p,
                    Name = p.Name,
                    DisplayName = p.DisplayName,
                    Distance = dist,
                    Health = hp,
                    MaxHealth = maxHp,
                    TeamColor = p.TeamColor and p.TeamColor.Color or Color3.fromRGB(200, 200, 200)
                })
            end
        end
        
        -- เรียงตามระยะทาง (ใกล้ไปไกล)
        table.sort(data, function(a, b) return a.Distance < b.Distance end)
        return data
    end

    RYS.RegisterModule("PlayerList", PlayerList)
    return PlayerList
end
