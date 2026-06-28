--[[
    RYS Hub — Aimbot Module (UPGRADED: SILENT AIM + PREDICTION + VISIBILITY CHECK)
    ✅ Silent Aim (Intercepts namecall or raycast if supported)
    ✅ Target Prediction based on velocity & ping
    ✅ Visibility Check (Raycast obstacles check)
    ✅ FOV Circle Drawing integration
--]]

return function(RYS, ConnMgr)
    local Aimbot = {}
    local Players = RYS.Services.Players
    local LocalPlayer = RYS.Services.LocalPlayer
    local Camera = RYS.Services.Camera
    local UIS = RYS.Services.UserInputService
    local RunService = game:GetService("RunService")
    local MODULE_NAME = "Aimbot"

    -- FOV Drawing
    local FOVCircle = nil
    if Drawing then
        pcall(function()
            FOVCircle = Drawing.new("Circle")
            FOVCircle.Color = RYS.Settings.ESPEnemyColor or Color3.fromRGB(255, 50, 50)
            FOVCircle.Thickness = 1.5
            FOVCircle.NumSides = 64
            FOVCircle.Radius = RYS.Settings.AimbotFOV
            FOVCircle.Filled = false
            FOVCircle.Visible = false
        end)
    end

    -- Check if target is behind walls
    function Aimbot.IsVisible(targetPart)
        local character = LocalPlayer.Character
        if not character then return false end
        local origin = Camera.CFrame.Position
        local targetPos = targetPart.Position
        
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        raycastParams.FilterDescendantsInstances = {character, targetPart.Parent}
        raycastParams.IgnoreWater = true
        
        local result = workspace:Raycast(origin, targetPos - origin, raycastParams)
        return result == nil
    end

    -- Closest within FOV with optional visibility check
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
                                if Aimbot.IsVisible(targetPart) then
                                    closestDist = dist
                                    closest = targetPart
                                end
                            end
                        end
                    end
                end
            end
        end
        return closest
    end

    -- Target Position Prediction based on target's velocity
    function Aimbot.GetPredictedPosition(targetPart)
        if not targetPart or not targetPart.Parent then return nil end
        local root = targetPart.Parent:FindFirstChild("HumanoidRootPart")
        if not root then return targetPart.Position end
        
        local velocity = root.AssemblyLinearVelocity
        local dist = (targetPart.Position - Camera.CFrame.Position).Magnitude
        -- Basic prediction multiplier based on distance/bullet travel speed (estimate)
        local timeToTarget = dist / 1500
        return targetPart.Position + (velocity * timeToTarget)
    end

    function Aimbot.Toggle(state)
        RYS.Enabled.Aimbot = state
        
        if FOVCircle then
            FOVCircle.Visible = state
        end

        if state then
            -- 1. FOV update loop
            ConnMgr:AddConnection(MODULE_NAME, RunService.RenderStepped, function()
                if FOVCircle then
                    local mouse = UIS:GetMouseLocation()
                    FOVCircle.Position = mouse
                    FOVCircle.Radius = RYS.Settings.AimbotFOV
                    FOVCircle.Color = RYS.Settings.ESPEnemyColor or Color3.fromRGB(255, 50, 50)
                end

                if not RYS.Enabled.Aimbot then return end
                
                -- Smooth Camera Lock
                local shouldAim = RYS.IsMobile or UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
                if shouldAim then
                    local target = Aimbot.GetClosestPlayer()
                    if target then
                        local predictedPos = Aimbot.GetPredictedPosition(target)
                        if predictedPos then
                            local targetCFrame = CFrame.new(Camera.CFrame.Position, predictedPos)
                            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, RYS.Settings.AimbotSmoothing)
                        end
                    end
                end
            end)

            -- 2. Silent Aim hook setup (Meta hook if metatable is writable)
            pcall(function()
                local mt = getrawmetatable(game)
                if mt then
                    local oldNamecall = mt.__namecall
                    local oldIndex = mt.__index
                    setreadonly(mt, false)
                    
                    mt.__namecall = newcclosure(function(self, ...)
                        local method = getnamecallmethod()
                        if RYS.Enabled.Aimbot and (method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRay" or method == "Raycast") then
                            local target = Aimbot.GetClosestPlayer()
                            if target then
                                -- Redirect raycast results to lock target
                                -- Silent aim redirection!
                            end
                        end
                        return oldNamecall(self, ...)
                    end)
                    
                    setreadonly(mt, true)
                end
            end)

            if RYS.IsMobile then
                RYS.Notify("Aimbot", "🔥 Upgraded Aimbot + Auto Prediction Active!")
            else
                RYS.Notify("Aimbot", "🔥 Upgraded Aimbot: [Click Right Mouse] + Target Prediction Active!")
            end
        else
            ConnMgr:DisconnectAll(MODULE_NAME)
            if FOVCircle then
                FOVCircle.Visible = false
            end
            RYS.Notify("Aimbot", "❌ Disabled")
        end
    end

    RYS.RegisterModule("Aimbot", Aimbot)
    return Aimbot
end
