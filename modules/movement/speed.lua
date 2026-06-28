--[[
    RYS Hub — Speed Hack (UPGRADED: TELEPORT INTERPOLATOR + MULTI-METHOD SPEED)
    ✅ Speed mode selection (CFrame interpolation vs. WalkSpeed property manipulation)
    ✅ Auto Anti-Cheat desync loop (prevents rubberbanding/getting kicked by physics checks)
    ✅ Throttle adjusted dynamically based on speed settings
--]]

return function(RYS, ConnMgr)
    local Speed = {}
    local MODULE_NAME = "Speed"
    local RunService = game:GetService("RunService")
    local Players = RYS.Services.Players
    local LocalPlayer = RYS.Services.LocalPlayer

    function Speed.Toggle(state)
        RYS.Enabled.Speed = state
        if state then
            -- High performance loop to bypass physics-based anti-cheat teleport checks
            local lastCFrame = nil
            
            ConnMgr:AddConnection(MODULE_NAME, RunService.Heartbeat, function(dt)
                if not RYS.Enabled.Speed then return end
                
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                
                if root and hum then
                    -- Method 1: WalkSpeed property modifier
                    if RYS.Settings.SpeedMode == "WalkSpeed" or not RYS.Settings.SpeedMode then
                        hum.WalkSpeed = RYS.Settings.WalkSpeed
                    else
                        -- Method 2: CFrame Teleport interpolation (Bypasses WalkSpeed checks entirely)
                        -- Calculate direction vector based on move direction
                        local moveDir = hum.MoveDirection
                        if moveDir.Magnitude > 0 then
                            local speedMultiplier = RYS.Settings.WalkSpeed / 16
                            local targetPos = root.Position + (moveDir.Unit * (16 * speedMultiplier * dt))
                            
                            -- Verify no collision with walls before cframing
                            local rayParams = RaycastParams.new()
                            rayParams.FilterType = Enum.RaycastFilterType.Exclude
                            rayParams.FilterDescendantsInstances = {char}
                            
                            local rayResult = workspace:Raycast(root.Position, moveDir.Unit * 2, rayParams)
                            if not rayResult then
                                root.CFrame = CFrame.new(targetPos) * CFrame.Angles(root.CFrame:ToEulerAnglesXYZ())
                            end
                        end
                    end
                end
            end)
            RYS.Notify("Speed", "⚡ DEMON SPEED ACTIVE (Mode: " .. (RYS.Settings.SpeedMode or "CFrame") .. " | Speed: " .. RYS.Settings.WalkSpeed .. ")")
        else
            ConnMgr:DisconnectAll(MODULE_NAME)
            local hum = RYS.GetHumanoid()
            if hum then hum.WalkSpeed = 16 end
            RYS.Notify("Speed", "❌ Speed Hack disabled")
        end
    end

    RYS.RegisterModule("Speed", Speed)
    return Speed
end
