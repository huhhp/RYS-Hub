--[[
    RYS Hub — Aimbot Module
    ✅ ใช้ ConnMgr จัดการ connection
    ✅ Disconnect จริงเมื่อปิด
--]]

return function(RYS, ConnMgr)
    local Aimbot = {}
    local Players = RYS.Services.Players
    local LocalPlayer = RYS.Services.LocalPlayer
    local Camera = RYS.Services.Camera
    local UIS = RYS.Services.UserInputService
    local MODULE_NAME = "Aimbot"

    function Aimbot.GetClosestPlayer()
        local closest = nil
        local closestDist = RYS.Settings.AimbotFOV
        local myRoot = RYS.GetRootPart()
        if not myRoot then return nil end

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and RYS.IsAlive(player) and not RYS.IsTeammate(player) then
                local char = player.Character
                if char then
                    local targetPart = char:FindFirstChild(RYS.Settings.AimbotTargetPart)
                    if targetPart then
                        local screenPos, onScreen = Camera:WorldToScreenPoint(targetPart.Position)
                        if onScreen then
                            local mouse = UIS:GetMouseLocation()
                            local dist = (Vector2.new(screenPos.X, screenPos.Y) - mouse).Magnitude
                            if dist < closestDist then
                                closestDist = dist
                                closest = targetPart
                            end
                        end
                    end
                end
            end
        end
        return closest
    end

    function Aimbot.Toggle(state)
        RYS.Enabled.Aimbot = state
        if state then
            -- Aimbot ต้อง RenderStepped จริงๆ เพราะเกี่ยวกับ Camera (ไม่ throttle)
            ConnMgr:AddConnection(MODULE_NAME, game:GetService("RunService").RenderStepped, function()
                if not RYS.Enabled.Aimbot then return end
                local shouldAim = RYS.IsMobile or UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
                if shouldAim then
                    local target = Aimbot.GetClosestPlayer()
                    if target then
                        local targetCFrame = CFrame.new(Camera.CFrame.Position, target.Position)
                        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, RYS.Settings.AimbotSmoothing)
                    end
                end
            end)
            if RYS.IsMobile then
                RYS.Notify("Aimbot", "✅ Auto Aimbot เปิดแล้ว! (ล็อคอัตโนมัติ)")
            else
                RYS.Notify("Aimbot", "✅ เปิดแล้ว — คลิกขวาค้างเพื่อล็อค!")
            end
        else
            ConnMgr:DisconnectAll(MODULE_NAME)
            RYS.Notify("Aimbot", "❌ ปิดแล้ว")
        end
    end

    RYS.RegisterModule("Aimbot", Aimbot)
    return Aimbot
end
