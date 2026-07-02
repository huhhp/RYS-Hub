--[[
    RYS Hub — Speed Hack Module v5.0 (UPGRADED)
    ⚡ ADVANCED MULTI-METHOD SPEED ENGINE
    
    Features:
    1. Method 1: WalkSpeed — เปลียนค่า properties ปกติ
    2. Method 2: CFrame — วาร์ปทีละนิด (Bypass Anti-Cheat ที่ล็อค WalkSpeed)
    3. Method 3: Velocity — เพิ่มแรงผลักดัน
    4. JumpPower Sync — ซิงค์ความสูงกระโดดเมื่อวิ่งเร็ว
    5. Respawn Recovery — วิ่งเร็วต่อเมื่อตายแล้วเกิดใหม่
--]]

return function(RYS, ConnMgr)
    local Speed = {}
    local MODULE_NAME = "Speed"
    local RunService = game:GetService("RunService")
    local LocalPlayer = RYS.Services.LocalPlayer

    -- ═══════════════════════════════════════
    -- METHODS
    -- ═══════════════════════════════════════
    local function MethodWalkSpeed(hum, speed)
        hum.WalkSpeed = speed
    end
    
    local function MethodCFrame(char, hum, root, speed, dt)
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            -- 16 คือความเร็วมาตรฐาน (Speed / 16 = ตัวคูณ)
            local speedMultiplier = speed / 16
            local targetPos = root.Position + (moveDir.Unit * (16 * speedMultiplier * dt))
            
            -- Raycast ตรวจจับกำแพง (กันทะลุแมพถ้าไม่เปิด Noclip)
            local rayParams = RaycastParams.new()
            rayParams.FilterType = Enum.RaycastFilterType.Exclude
            rayParams.FilterDescendantsInstances = {char}
            
            -- ยิงเรดาร์ไปข้างหน้า
            local rayResult = workspace:Raycast(root.Position, moveDir.Unit * 2, rayParams)
            if not rayResult then
                -- ถ้าไม่ชน ให้วาร์ป (Interpolate CFrame)
                root.CFrame = CFrame.new(targetPos) * CFrame.Angles(root.CFrame:ToEulerAnglesXYZ())
            end
        end
    end
    
    local function MethodVelocity(hum, root, speed)
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            -- แทนที่ความเร็วแกน X และ Z
            local currentVel = root.Velocity
            root.Velocity = Vector3.new(moveDir.X * speed, currentVel.Y, moveDir.Z * speed)
        end
    end

    -- ═══════════════════════════════════════
    -- MAIN TOGGLE
    -- ═══════════════════════════════════════
    function Speed.Toggle(state)
        RYS.Enabled.Speed = state
        if state then
            -- High Performance Loop
            ConnMgr:AddConnection(MODULE_NAME, RunService.Heartbeat, function(dt)
                if not RYS.Enabled.Speed then return end
                
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                
                if root and hum then
                    local targetSpeed = RYS.Settings.WalkSpeed or 50
                    local mode = RYS.Settings.SpeedMode or "WalkSpeed"
                    
                    if mode == "WalkSpeed" then
                        MethodWalkSpeed(hum, targetSpeed)
                    elseif mode == "CFrame" then
                        MethodCFrame(char, hum, root, targetSpeed, dt)
                    elseif mode == "Velocity" then
                        MethodVelocity(hum, root, targetSpeed)
                    end
                    
                    -- JumpPower Sync (ถ้าเปิดให้ซิงค์กระโดดกับความเร็ว)
                    if RYS.Settings.SyncJumpPower then
                        pcall(function()
                            hum.JumpPower = math.clamp(targetSpeed * 1.5, 50, 200)
                        end)
                    end
                end
            end)
            
            -- Respawn Recovery (แม้จะไม่ค่อยจำเป็นเพราะทำใน Heartbeat แล้ว แต่มั่นใจไว้ก่อน)
            ConnMgr:AddConnection(MODULE_NAME .. "_Respawn", LocalPlayer.CharacterAdded, function(newChar)
                if RYS.Enabled.Speed and (RYS.Settings.SpeedMode == "WalkSpeed" or not RYS.Settings.SpeedMode) then
                    task.wait(0.5)
                    local hum = newChar:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum.WalkSpeed = RYS.Settings.WalkSpeed or 50
                    end
                end
            end)
            
            RYS.Notify("Speed", "⚡ วิ่งเร็วสายฟ้า! (Mode: " .. (RYS.Settings.SpeedMode or "WalkSpeed") .. " | Speed: " .. (RYS.Settings.WalkSpeed or 50) .. ")")
        else
            ConnMgr:DisconnectAll(MODULE_NAME)
            ConnMgr:DisconnectAll(MODULE_NAME .. "_Respawn")
            
            local hum = RYS.GetHumanoid()
            if hum then
                pcall(function() hum.WalkSpeed = 16 end)
                if RYS.Settings.SyncJumpPower then
                    pcall(function() hum.JumpPower = 50 end)
                end
            end
            
            RYS.Notify("Speed", "❌ ปิดวิ่งเร็วแล้ว")
        end
    end

    RYS.RegisterModule("Speed", Speed)
    return Speed
end
