--[[
    RYS Hub — God Mode Module
    ✅ Throttle 0.1s สำหรับ health regen
--]]

return function(RYS, ConnMgr)
    local GodMode = {}
    local MODULE_NAME = "GodMode"

    function GodMode.Toggle(state)
        RYS.Enabled.GodMode = state
        if state then
            local char = RYS.GetCharacter()
            local humanoid = RYS.GetHumanoid()
            if humanoid then
                -- ✅ Throttle 0.1s สำหรับ health — เร็วพอที่จะไม่ตาย
                ConnMgr:AddThrottled(MODULE_NAME, 0.1, function()
                    if not RYS.Enabled.GodMode then return end
                    local hum = RYS.GetHumanoid()
                    if hum then
                        hum.Health = hum.MaxHealth
                    end
                end)

                -- Method 2: Remove/Recreate Humanoid
                pcall(function()
                    local oldHP = humanoid.MaxHealth
                    humanoid:Remove()
                    task.wait(0.1)
                    local newHum = Instance.new("Humanoid")
                    newHum.MaxHealth = oldHP
                    newHum.Health = oldHP
                    newHum.Parent = char
                end)
            end
            RYS.Notify("God Mode", "✅ ไม่ตายแล้ว!")
        else
            ConnMgr:DisconnectAll(MODULE_NAME)
            RYS.Notify("God Mode", "❌ ปิดแล้ว ระวังตัวด้วย!")
        end
    end

    RYS.RegisterModule("GodMode", GodMode)
    return GodMode
end
