--[[
    RYS Hub — Anti-AFK Module
--]]

return function(RYS, ConnMgr)
    local AntiAFK = {}
    local MODULE_NAME = "AntiAFK"

    function AntiAFK.Toggle(state)
        RYS.Enabled.AntiAFK = state
        if state then
            local vu = game:GetService("VirtualUser")
            local Camera = RYS.Services.Camera
            ConnMgr:AddConnection(MODULE_NAME, RYS.Services.LocalPlayer.Idled, function()
                if RYS.Enabled.AntiAFK then
                    vu:Button2Down(Vector2.new(0, 0), Camera.CFrame)
                    task.wait(1)
                    vu:Button2Up(Vector2.new(0, 0), Camera.CFrame)
                end
            end)
            RYS.Notify("Anti-AFK", "✅ ไม่โดนเตะจาก AFK แล้ว!")
        else
            ConnMgr:DisconnectAll(MODULE_NAME)
            RYS.Notify("Anti-AFK", "❌ ปิดแล้ว")
        end
    end

    RYS.RegisterModule("AntiAFK", AntiAFK)
    return AntiAFK
end
