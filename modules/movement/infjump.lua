--[[
    RYS Hub — Infinite Jump Module v5.0 (UPGRADED)
    🦘 ADVANCED MULTI-JUMP ENGINE
    
    Features:
    1. JumpRequest Hook — กระโดดกลางอากาศไม่จำกัด
    2. JumpPower Boost — เพิ่มแรงกระโดดตาม Settings
    3. Anti-Fall Damage — ยกเลิกสถานะ Freefall เมื่อลง
    4. Mobile Support — รองรับ Touch jump button
    5. Double/Triple Jump Counter — นับจำนวนกระโดดต่อเนื่อง
--]]

return function(RYS, ConnMgr)
    local InfJump = {}
    local MODULE_NAME = "InfJump"
    local UIS = RYS.Services.UserInputService
    
    InfJump.JumpCount = 0
    InfJump.MaxCombo = 0

    function InfJump.Toggle(state)
        RYS.Enabled.InfiniteJump = state
        if state then
            -- Main: JumpRequest hook
            ConnMgr:AddConnection(MODULE_NAME, UIS.JumpRequest, function()
                if not RYS.Enabled.InfiniteJump then return end
                local hum = RYS.GetHumanoid()
                if hum then
                    -- Force jump state แม้จะอยู่กลางอากาศ
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    
                    -- Apply JumpPower จาก Settings
                    pcall(function()
                        hum.JumpPower = RYS.Settings.JumpPower
                        hum.JumpHeight = 0 -- ใช้ JumpPower แทน JumpHeight
                    end)
                    
                    -- Track jump combo
                    InfJump.JumpCount = InfJump.JumpCount + 1
                    if InfJump.JumpCount > InfJump.MaxCombo then
                        InfJump.MaxCombo = InfJump.JumpCount
                    end
                end
            end)
            
            -- Anti-Fall Damage: ยกเลิก Freefall state → Running เมื่อกำลังจะตกพื้น
            ConnMgr:AddThrottled(MODULE_NAME .. "_AntiFall", 0.1, function()
                if not RYS.Enabled.InfiniteJump then return end
                local hum = RYS.GetHumanoid()
                if hum then
                    local currentState = hum:GetState()
                    -- ถ้ากำลัง freefall + ใกล้พื้น → force Running
                    if currentState == Enum.HumanoidStateType.Freefall then
                        local root = RYS.GetRootPart()
                        if root then
                            -- Raycast ลงพื้น
                            local ray = workspace:Raycast(root.Position, Vector3.new(0, -8, 0))
                            if ray then
                                -- ใกล้พื้นแล้ว → ป้องกัน fall damage
                                hum:ChangeState(Enum.HumanoidStateType.Landing)
                            end
                        end
                    end
                    
                    -- Reset counter เมื่อแตะพื้น
                    if currentState == Enum.HumanoidStateType.Running or
                       currentState == Enum.HumanoidStateType.Landed then
                        InfJump.JumpCount = 0
                    end
                end
            end)
            
            -- Respawn recovery: ติดตั้งใหม่เมื่อ respawn
            ConnMgr:AddConnection(MODULE_NAME .. "_Respawn", 
                RYS.Services.LocalPlayer.CharacterAdded, function()
                    if RYS.Enabled.InfiniteJump then
                        task.wait(0.5)
                        local hum = RYS.GetHumanoid()
                        if hum then
                            hum.JumpPower = RYS.Settings.JumpPower
                        end
                    end
                end)
            
            RYS.Notify("Infinite Jump", "🦘 กระโดดไม่จำกัด + Anti-Fall + JumpPower: " .. RYS.Settings.JumpPower)
        else
            ConnMgr:DisconnectAll(MODULE_NAME)
            ConnMgr:DisconnectAll(MODULE_NAME .. "_AntiFall")
            ConnMgr:DisconnectAll(MODULE_NAME .. "_Respawn")
            -- Reset JumpPower
            local hum = RYS.GetHumanoid()
            if hum then
                pcall(function() hum.JumpPower = 50 end)
            end
            RYS.Notify("Infinite Jump", "❌ ปิดแล้ว — Max Combo: " .. InfJump.MaxCombo)
        end
    end

    RYS.RegisterModule("InfJump", InfJump)
    return InfJump
end
