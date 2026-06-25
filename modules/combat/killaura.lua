--[[
    RYS Hub — Kill Aura Module
    ✅ ใช้ ConnMgr + Throttle
--]]

return function(RYS, ConnMgr)
    local KillAura = {}
    local Players = RYS.Services.Players
    local LocalPlayer = RYS.Services.LocalPlayer
    local MODULE_NAME = "KillAura"

    function KillAura.Toggle(state)
        RYS.Enabled.KillAura = state
        if state then
            -- ✅ Throttle 0.1s — ไม่จำเป็นต้องตรวจทุกเฟรม
            ConnMgr:AddThrottled(MODULE_NAME, 0.1, function()
                if not RYS.Enabled.KillAura then return end
                local myRoot = RYS.GetRootPart()
                if not myRoot then return end

                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and RYS.IsAlive(player) and not RYS.IsTeammate(player) then
                        local targetRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        if targetRoot then
                            local dist = RYS.GetDistance(myRoot.Position, targetRoot.Position)
                            if dist <= RYS.Settings.KillAuraRange then
                                -- ใช้ Tool
                                local char = RYS.GetCharacter()
                                if char then
                                    for _, tool in ipairs(char:GetChildren()) do
                                        if tool:IsA("Tool") then
                                            tool:Activate()
                                        end
                                    end
                                end
                                -- Fire touch
                                pcall(function()
                                    firetouchinterest(myRoot, targetRoot, 0)
                                    task.wait()
                                    firetouchinterest(myRoot, targetRoot, 1)
                                end)
                            end
                        end
                    end
                end
            end)
            RYS.Notify("Kill Aura", "✅ โจมตีอัตโนมัติรัศมี " .. RYS.Settings.KillAuraRange .. " studs!")
        else
            ConnMgr:DisconnectAll(MODULE_NAME)
            RYS.Notify("Kill Aura", "❌ ปิดแล้ว")
        end
    end

    RYS.RegisterModule("KillAura", KillAura)
    return KillAura
end
