--[[
    RYS Hub — Speed Hack (Optimized)
    ✅ Throttle 0.5s — ไม่จำเป็นต้อง set WalkSpeed ทุกเฟรม
--]]

return function(RYS, ConnMgr)
    local Speed = {}
    local MODULE_NAME = "Speed"

    function Speed.Toggle(state)
        RYS.Enabled.Speed = state
        if state then
            -- ✅ OPTIMIZED: Throttle 0.5s — set WalkSpeed 2 ครั้งต่อวินาที (เพียงพอแล้ว)
            ConnMgr:AddThrottled(MODULE_NAME, 0.5, function()
                if not RYS.Enabled.Speed then return end
                local hum = RYS.GetHumanoid()
                if hum then
                    hum.WalkSpeed = RYS.Settings.WalkSpeed
                end
            end)
            RYS.Notify("Speed", "✅ ความเร็ว: " .. RYS.Settings.WalkSpeed)
        else
            ConnMgr:DisconnectAll(MODULE_NAME)
            local hum = RYS.GetHumanoid()
            if hum then hum.WalkSpeed = 16 end
            RYS.Notify("Speed", "❌ ปิดแล้ว กลับเป็นปกติ")
        end
    end

    RYS.RegisterModule("Speed", Speed)
    return Speed
end
