--[[
    RYS Hub — Fly Module
    ✅ ใช้ ConnMgr จัดการ
    ✅ Cleanup BodyVelocity/BodyGyro เมื่อปิด
--]]

return function(RYS, ConnMgr)
    local Fly = {}
    local UIS = RYS.Services.UserInputService
    local Camera = RYS.Services.Camera
    local MODULE_NAME = "Fly"
    local flyBody = nil
    local flyGyro = nil

    function Fly.Toggle(state)
        RYS.Enabled.Fly = state
        local rootPart = RYS.GetRootPart()
        local humanoid = RYS.GetHumanoid()

        if state and rootPart then
            flyBody = Instance.new("BodyVelocity")
            flyBody.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            flyBody.Velocity = Vector3.new(0, 0, 0)
            flyBody.Parent = rootPart

            flyGyro = Instance.new("BodyGyro")
            flyGyro.Name = "RYS_FlyGyro"
            flyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            flyGyro.P = 9e4
            flyGyro.Parent = rootPart

            -- Fly ต้อง RenderStepped จริง (camera-relative movement)
            ConnMgr:AddConnection(MODULE_NAME, game:GetService("RunService").RenderStepped, function()
                if not RYS.Enabled.Fly or not flyBody or not flyBody.Parent then return end
                local dir = Vector3.new(0, 0, 0)

                if RYS.IsMobile then
                    local hum = RYS.GetHumanoid()
                    if hum then
                        local moveDir = hum.MoveDirection
                        if moveDir.Magnitude > 0 then
                            dir = dir + moveDir.Unit
                        end
                    end
                    if humanoid and humanoid:GetState() == Enum.HumanoidStateType.Jumping then
                        dir = dir + Vector3.new(0, 1, 0)
                    end
                else
                    if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
                    if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
                    if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
                    if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
                    if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
                    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end
                end

                flyBody.Velocity = dir * RYS.Settings.FlySpeed
                flyGyro.CFrame = Camera.CFrame
            end)

            if RYS.IsMobile then
                RYS.Notify("Fly", "✅ บินได้แล้ว! ใช้ Joystick เดิน + Jump เพื่อบินขึ้น")
            else
                RYS.Notify("Fly", "✅ บินได้แล้ว! WASD+Space/Ctrl")
            end
        else
            ConnMgr:DisconnectAll(MODULE_NAME)
            if flyBody then pcall(function() flyBody:Destroy() end) flyBody = nil end
            if flyGyro then pcall(function() flyGyro:Destroy() end) flyGyro = nil end
            local rp = RYS.GetRootPart()
            if rp then
                local g = rp:FindFirstChild("RYS_FlyGyro")
                if g then g:Destroy() end
            end
            RYS.Notify("Fly", "❌ ปิดบินแล้ว")
        end
    end

    RYS.RegisterModule("Fly", Fly)
    return Fly
end
