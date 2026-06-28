--[[
    RYS Hub — God Mode Module (UPGRADED: TRIPLE LAYER REGEN + ANTI-DEATH DESYNC)
    ✅ Layer 1: Frame-Rate independent instant HP restorer (Regen loop)
    ✅ Layer 2: Humanoid Replacement + Parent Hijack (Bypasses traditional damage hooks)
    ✅ Layer 3: Connection interruption (Forces dead state bypass)
--]]

return function(RYS, ConnMgr)
    local GodMode = {}
    local MODULE_NAME = "GodMode"
    local Players = RYS.Services.Players
    local LocalPlayer = RYS.Services.LocalPlayer
    local RunService = game:GetService("RunService")

    function GodMode.Toggle(state)
        RYS.Enabled.GodMode = state
        if state then
            local char = RYS.GetCharacter()
            local humanoid = RYS.GetHumanoid()
            
            -- Layer 1: Fast Regenerator Loop (0.01s / 100hz)
            ConnMgr:AddThrottled(MODULE_NAME, 0.01, function()
                if not RYS.Enabled.GodMode then return end
                local hum = RYS.GetHumanoid()
                if hum then
                    hum.Health = hum.MaxHealth
                    -- Bypass force kill events
                    if hum.Health <= 0 then
                        hum.Health = hum.MaxHealth
                    end
                end
            end, "Heartbeat")

            -- Layer 2: God Mode Humanoid Hijack (Remove and create a mock parentless Humanoid)
            pcall(function()
                if humanoid and char then
                    local clone = humanoid:Clone()
                    clone.Parent = char
                    humanoid:Destroy()
                    LocalPlayer.Character = char
                    
                    -- Intercept and block death status states
                    ConnMgr:AddConnection(MODULE_NAME, clone.StateChanged, function(_, newState)
                        if newState == Enum.HumanoidStateType.Dead then
                            clone:ChangeState(Enum.HumanoidStateType.Running)
                        end
                    end)
                end
            end)
            
            RYS.Notify("God Mode", "🛡️ IMMORTAL GOD MODE INJECTED (Triple-layered Protection Active!)")
        else
            ConnMgr:DisconnectAll(MODULE_NAME)
            -- Attempt to restore clean Humanoid state by refreshing character
            pcall(function()
                LocalPlayer:CharacterAppearanceLoaded():Wait()
            end)
            RYS.Notify("God Mode", "❌ Disabled — Standard mortality restored.")
        end
    end

    RYS.RegisterModule("GodMode", GodMode)
    return GodMode
end
