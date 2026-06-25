--[[
    RYS Hub — Hitbox Expander (Optimized)
    ✅ Throttle 0.2s แทน RenderStepped ทุกเฟรม
    ✅ Proper cleanup เมื่อปิด
--]]

return function(RYS, ConnMgr)
    local Hitbox = {}
    local Players = RYS.Services.Players
    local LocalPlayer = RYS.Services.LocalPlayer
    local MODULE_NAME = "Hitbox"

    function Hitbox.Toggle(state)
        RYS.Enabled.HitboxExpander = state
        if state then
            -- ✅ OPTIMIZED: Throttle 0.2s — Hitbox ไม่ต้อง update ทุกเฟรม
            ConnMgr:AddThrottled(MODULE_NAME, 0.2, function()
                if not RYS.Enabled.HitboxExpander then return end
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                        if rootPart then
                            rootPart.Size = Vector3.new(
                                RYS.Settings.HitboxSize,
                                RYS.Settings.HitboxSize,
                                RYS.Settings.HitboxSize
                            )
                            rootPart.Transparency = 0.8
                            rootPart.BrickColor = BrickColor.new("Really red")
                            rootPart.Material = Enum.Material.ForceField
                            rootPart.CanCollide = false
                        end
                    end
                end
            end)
            RYS.Notify("Hitbox", "✅ ขยาย Hitbox ศัตรู: " .. RYS.Settings.HitboxSize)
        else
            ConnMgr:DisconnectAll(MODULE_NAME)
            -- Reset hitbox
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                    if rootPart then
                        rootPart.Size = Vector3.new(2, 2, 1)
                        rootPart.Transparency = 1
                    end
                end
            end
            RYS.Notify("Hitbox", "❌ ปิดแล้ว")
        end
    end

    RYS.RegisterModule("Hitbox", Hitbox)
    return Hitbox
end
