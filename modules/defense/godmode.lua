--[[
    RYS Hub — God Mode Module v5.0 (UPGRADED)
    🛡️ QUAD-LAYER IMMORTALITY ENGINE
    
    Layer 1: 100Hz Health Restorer — ตั้งเลือดเต็มทุก 0.01 วินาที
    Layer 2: Humanoid State Block — บล็อค Dead state
    Layer 3: ForceField Generator — สร้าง ForceField ล้อมรอบ
    Layer 4: Respawn Recovery — ติดตั้งใหม่อัตโนมัติเมื่อตาย
    
    ⚠️ ไม่ทำ Humanoid destroy แล้ว (เดิมมี bug พัง animation)
--]]

return function(RYS, ConnMgr)
    local GodMode = {}
    local MODULE_NAME = "GodMode"
    local LocalPlayer = RYS.Services.LocalPlayer
    local RunService = game:GetService("RunService")
    
    local forceField = nil
    local stateBlockConn = nil

    local function ApplyGodMode(char)
        if not char then return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        
        -- Layer 2: Block Dead state
        pcall(function()
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        end)
        
        -- State change interceptor
        stateBlockConn = humanoid.StateChanged:Connect(function(_, newState)
            if not RYS.Enabled.GodMode then return end
            if newState == Enum.HumanoidStateType.Dead then
                pcall(function()
                    humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    humanoid.Health = humanoid.MaxHealth
                end)
            end
        end)
        
        -- Layer 3: ForceField (visual + damage block)
        pcall(function()
            if not char:FindFirstChildOfClass("ForceField") then
                forceField = Instance.new("ForceField")
                forceField.Visible = false  -- ซ่อน ForceField (ไม่เห็นว่าเปิด god mode)
                forceField.Parent = char
            end
        end)
    end

    function GodMode.Toggle(state)
        RYS.Enabled.GodMode = state
        if state then
            -- Apply ครั้งแรก
            ApplyGodMode(RYS.GetCharacter())
            
            -- Layer 1: 100Hz Health Restorer (เร็วมาก ตั้งเลือดเต็มก่อนเกมจะลงโทษ)
            ConnMgr:AddThrottled(MODULE_NAME, 0.01, function()
                if not RYS.Enabled.GodMode then return end
                local hum = RYS.GetHumanoid()
                if hum then
                    -- Force health to max
                    if hum.Health < hum.MaxHealth then
                        hum.Health = hum.MaxHealth
                    end
                    -- Re-enable Running ถ้าถูก force Dead
                    if hum:GetState() == Enum.HumanoidStateType.Dead then
                        pcall(function()
                            hum:ChangeState(Enum.HumanoidStateType.Running)
                        end)
                    end
                end
            end, "Heartbeat")
            
            -- Layer 4: Respawn Recovery
            ConnMgr:AddConnection(MODULE_NAME .. "_Respawn",
                LocalPlayer.CharacterAdded, function(newChar)
                    if RYS.Enabled.GodMode then
                        task.wait(0.3)
                        -- Disconnect old state block
                        if stateBlockConn then
                            pcall(function() stateBlockConn:Disconnect() end)
                        end
                        ApplyGodMode(newChar)
                    end
                end)
            
            -- Extra: Block damage remotes ที่ส่ง damage event
            pcall(function()
                local hum = RYS.GetHumanoid()
                if hum then
                    ConnMgr:AddConnection(MODULE_NAME .. "_DMG", hum.HealthChanged, function(newHealth)
                        if RYS.Enabled.GodMode and newHealth < hum.MaxHealth then
                            hum.Health = hum.MaxHealth
                        end
                    end)
                end
            end)
            
            RYS.Notify("God Mode", "🛡️ IMMORTAL GOD MODE ACTIVE!\n4 Layers: Regen + StateBlock + ForceField + Respawn")
        else
            ConnMgr:DisconnectAll(MODULE_NAME)
            ConnMgr:DisconnectAll(MODULE_NAME .. "_Respawn")
            ConnMgr:DisconnectAll(MODULE_NAME .. "_DMG")
            
            -- Cleanup
            if stateBlockConn then
                pcall(function() stateBlockConn:Disconnect() end)
                stateBlockConn = nil
            end
            
            -- Remove ForceField
            pcall(function()
                local char = RYS.GetCharacter()
                if char then
                    local ff = char:FindFirstChildOfClass("ForceField")
                    if ff then ff:Destroy() end
                end
                if forceField then forceField:Destroy(); forceField = nil end
            end)
            
            -- Re-enable Dead state
            pcall(function()
                local hum = RYS.GetHumanoid()
                if hum then
                    hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
                end
            end)
            
            RYS.Notify("God Mode", "❌ ปิดแล้ว — กลับเป็นมนุษย์ธรรมดา")
        end
    end

    RYS.RegisterModule("GodMode", GodMode)
    return GodMode
end
