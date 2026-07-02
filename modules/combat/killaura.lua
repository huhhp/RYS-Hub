--[[
    RYS Hub — Kill Aura Module v5.0 (UPGRADED)
    ⚔️ GOD KILL AURA ENGINE
    
    Features:
    1. Multi-Target (AOE) — โจมตีหลายคนพร้อมกันในระยะ
    2. Team Check — ไม่ตีเพื่อนร่วมทีม
    3. Auto-Equip — หาอาวุธที่แรงที่สุดมาถืออัตโนมัติ
    4. Backstab/Rage Mode — วาร์ปไปแทงข้างหลัง
    5. Anti-Delay Touch — รัว TouchInterest ทะลุ cooldown
--]]

return function(RYS, ConnMgr)
    local KillAura = {}
    local Players = RYS.Services.Players
    local LocalPlayer = RYS.Services.LocalPlayer
    local MODULE_NAME = "KillAura"

    local function IsEnemy(player)
        if player == LocalPlayer then return false end
        if RYS.Settings.TeamCheck and LocalPlayer.Team and player.Team then
            return player.Team ~= LocalPlayer.Team
        end
        -- ถ้าในเกมมี Attribute "IsMonster" หรืออะไรทำนองนั้น สามารถเช็คได้ที่นี่
        return true
    end

    local function GetBestWeapon()
        local char = RYS.GetCharacter()
        if not char then return nil end
        
        -- ถ้าถืออยู่แล้วใช้เลย
        local currentTool = char:FindFirstChildOfClass("Tool")
        if currentTool then return currentTool end
        
        -- หาจาก Backpack (สามารถพัฒนาให้เลือกอันที่มี damage สูงสุดได้ถ้ามีข้อมูล)
        local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
        if backpack then
            local tool = backpack:FindFirstChildOfClass("Tool")
            if tool then
                tool.Parent = char
                return tool
            end
        end
        return nil
    end

    function KillAura.Toggle(state)
        RYS.Enabled.KillAura = state
        if state then
            -- Tickrate สูง (50Hz)
            ConnMgr:AddThrottled(MODULE_NAME, 0.02, function()
                if not RYS.Enabled.KillAura then return end
                local myRoot = RYS.GetRootPart()
                if not myRoot then return end
                
                local range = RYS.Settings.KillAuraRange or 20
                local tool = GetBestWeapon()
                local attacked = false
                
                -- ตีทุกคนในระยะ (AOE Mode) ไม่ใช่แค่คนเดียว
                for _, player in ipairs(Players:GetPlayers()) do
                    if IsEnemy(player) and player.Character then
                        local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                        local targetHum = player.Character:FindFirstChildOfClass("Humanoid")
                        
                        if targetRoot and targetHum and targetHum.Health > 0 then
                            local dist = (myRoot.Position - targetRoot.Position).Magnitude
                            if dist <= range then
                                -- 1. Equip & Activate
                                if tool then
                                    tool:Activate()
                                end
                                
                                -- 2. Rage Mode (Backstab TP)
                                -- ไปโผล่ข้างหลังเป้าหมายที่ใกล้ที่สุด (ป้องกันการ TP สลับไปมามั่วๆ)
                                if RYS.Settings.RageMode and not attacked then
                                    pcall(function()
                                        myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3)
                                    end)
                                end
                                
                                -- 3. Anti-Delay Touch
                                if firetouchinterest then
                                    pcall(function()
                                        -- จำลองแตะแล้วปล่อยรัวๆ
                                        firetouchinterest(myRoot, targetRoot, 0)
                                        task.wait()
                                        firetouchinterest(myRoot, targetRoot, 1)
                                        
                                        -- ถ้าอาวุธมี Handle ก็ใช้ Handle แตะด้วย
                                        if tool and tool:FindFirstChild("Handle") then
                                            firetouchinterest(tool.Handle, targetRoot, 0)
                                            task.wait()
                                            firetouchinterest(tool.Handle, targetRoot, 1)
                                        end
                                    end)
                                end
                                
                                attacked = true
                            end
                        end
                    end
                end
            end)
            RYS.Notify("Kill Aura", "⚔️ GOD AURA Active!\nAOE Target + TeamCheck + AntiDelay")
        else
            ConnMgr:DisconnectAll(MODULE_NAME)
            RYS.Notify("Kill Aura", "❌ ปิดแล้ว")
        end
    end

    RYS.RegisterModule("KillAura", KillAura)
    return KillAura
end
