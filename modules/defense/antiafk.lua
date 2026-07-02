--[[
    RYS Hub — Anti-AFK Module v5.0 (UPGRADED)
    💤 MULTI-METHOD AFK PREVENTION
    
    Method 1: VirtualUser — จำลองคลิกเมาส์เมื่อ Idle
    Method 2: VirtualInputManager — จำลองกดคีย์บอร์ดเป็นระยะ
    Method 3: Character Micro-Movement — ขยับตัวละครเล็กน้อยทุก interval
    Method 4: Camera Jitter — สั่นกล้องเบาๆ
--]]

return function(RYS, ConnMgr)
    local AntiAFK = {}
    local MODULE_NAME = "AntiAFK"
    local LocalPlayer = RYS.Services.LocalPlayer
    local Camera = RYS.Services.Camera

    function AntiAFK.Toggle(state)
        RYS.Enabled.AntiAFK = state
        if state then
            -- Method 1: VirtualUser (หลัก — ตอบ Idle event)
            pcall(function()
                local vu = game:GetService("VirtualUser")
                ConnMgr:AddConnection(MODULE_NAME, LocalPlayer.Idled, function()
                    if not RYS.Enabled.AntiAFK then return end
                    vu:Button2Down(Vector2.new(0, 0), Camera.CFrame)
                    task.wait(0.5)
                    vu:Button2Up(Vector2.new(0, 0), Camera.CFrame)
                end)
            end)
            
            -- Method 2: Periodic key simulation (ทุก 60 วินาที)
            ConnMgr:AddThrottled(MODULE_NAME .. "_KeySim", 60.0, function()
                if not RYS.Enabled.AntiAFK then return end
                pcall(function()
                    local vu = game:GetService("VirtualUser")
                    -- จำลองกด Space แล้วปล่อย
                    vu:SetKeyDown("0x20") -- Space
                    task.wait(0.1)
                    vu:SetKeyUp("0x20")
                end)
                -- Method 3 Fallback: ขยับ Mouse เล็กน้อย
                pcall(function()
                    local vim = game:GetService("VirtualInputManager")
                    vim:SendMouseMoveEvent(
                        math.random(100, 500),
                        math.random(100, 500),
                        game:GetService("Workspace")
                    )
                end)
            end)
            
            -- Method 3: Character micro-movement (ทุก 120 วินาที)
            ConnMgr:AddThrottled(MODULE_NAME .. "_Move", 120.0, function()
                if not RYS.Enabled.AntiAFK then return end
                local root = RYS.GetRootPart()
                if root then
                    pcall(function()
                        -- ขยับตัวละคร 0.01 stud แล้วกลับ (มองไม่เห็นด้วยตา)
                        local origCF = root.CFrame
                        root.CFrame = origCF * CFrame.new(0.01, 0, 0)
                        task.wait(0.1)
                        root.CFrame = origCF
                    end)
                end
            end)
            
            -- Method 4: Camera micro-jitter (ทุก 90 วินาที)
            ConnMgr:AddThrottled(MODULE_NAME .. "_CamJit", 90.0, function()
                if not RYS.Enabled.AntiAFK then return end
                pcall(function()
                    local origFOV = Camera.FieldOfView
                    Camera.FieldOfView = origFOV + 0.01
                    task.wait(0.2)
                    Camera.FieldOfView = origFOV
                end)
            end)

            RYS.Notify("Anti-AFK", "💤 4-Method AFK Shield เปิดแล้ว!\nVirtualUser + KeySim + MicroMove + CamJitter")
        else
            ConnMgr:DisconnectAll(MODULE_NAME)
            ConnMgr:DisconnectAll(MODULE_NAME .. "_KeySim")
            ConnMgr:DisconnectAll(MODULE_NAME .. "_Move")
            ConnMgr:DisconnectAll(MODULE_NAME .. "_CamJit")
            RYS.Notify("Anti-AFK", "❌ ปิดแล้ว")
        end
    end

    RYS.RegisterModule("AntiAFK", AntiAFK)
    return AntiAFK
end
