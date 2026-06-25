--[[
    RYS Hub — Anti-Kick Module
--]]

return function(RYS, ConnMgr)
    local AntiKick = {}
    local MODULE_NAME = "AntiKick"

    function AntiKick.Toggle(state)
        RYS.Enabled.AntiKick = state
        if state then
            pcall(function()
                local oldNamecall
                oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                    local method = getnamecallmethod()
                    if method == "Kick" or method == "kick" then
                        return nil
                    end
                    return oldNamecall(self, ...)
                end)
            end)
            RYS.Notify("Anti-Kick", "✅ ป้องกันการเตะออกแล้ว!")
        else
            RYS.Notify("Anti-Kick", "❌ ปิดแล้ว")
        end
    end

    RYS.RegisterModule("AntiKick", AntiKick)
    return AntiKick
end
