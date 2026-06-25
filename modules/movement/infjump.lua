--[[
    RYS Hub — Infinite Jump Module
--]]

return function(RYS, ConnMgr)
    local InfJump = {}
    local MODULE_NAME = "InfJump"

    function InfJump.Toggle(state)
        RYS.Enabled.InfiniteJump = state
        if state then
            ConnMgr:AddConnection(MODULE_NAME, RYS.Services.UserInputService.JumpRequest, function()
                if not RYS.Enabled.InfiniteJump then return end
                local hum = RYS.GetHumanoid()
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
            RYS.Notify("Infinite Jump", "✅ กระโดดไม่จำกัด!")
        else
            ConnMgr:DisconnectAll(MODULE_NAME)
            RYS.Notify("Infinite Jump", "❌ ปิดแล้ว")
        end
    end

    RYS.RegisterModule("InfJump", InfJump)
    return InfJump
end
