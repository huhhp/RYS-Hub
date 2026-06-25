--[[
    RYS Hub — Noclip Module
    ✅ ใช้ Stepped (ถูกต้องสำหรับ collision)
    ✅ ConnMgr cleanup
--]]

return function(RYS, ConnMgr)
    local Noclip = {}
    local MODULE_NAME = "Noclip"

    function Noclip.Toggle(state)
        RYS.Enabled.Noclip = state
        if state then
            ConnMgr:AddConnection(MODULE_NAME, game:GetService("RunService").Stepped, function()
                if not RYS.Enabled.Noclip then return end
                local char = RYS.GetCharacter()
                if char then
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
            RYS.Notify("Noclip", "✅ ทะลุกำแพงได้แล้ว!")
        else
            ConnMgr:DisconnectAll(MODULE_NAME)
            RYS.Notify("Noclip", "❌ ปิดแล้ว")
        end
    end

    RYS.RegisterModule("Noclip", Noclip)
    return Noclip
end
