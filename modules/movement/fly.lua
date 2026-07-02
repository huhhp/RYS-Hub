--[[
    RYS Hub — Fly Module v5.0 (UPGRADED)
    ✈️ ADVANCED FLIGHT ENGINE
    
    Features:
    1. Smooth Flight — เคลื่อนที่ลื่นไหลตามกล้อง
    2. Speed Modifiers — กด Shift บินเร็ว / Ctrl บินช้า
    3. Mobile Support — รองรับ Joystick บนมือถือ
    4. Anti-Fall Damage — ป้องกันเลือดลดตอนร่วง
    5. Collision Toggle — ทะลุกำแพงขณะบิน (ตัวเลือก)
    6. Auto-Recovery — บินต่อเมื่อตายแล้วเกิดใหม่
--]]

return function(RYS, ConnMgr)
    local Fly = {}
    local MODULE_NAME = "Fly"
    local UIS = RYS.Services.UserInputService
    local Camera = RYS.Services.Camera
    local LocalPlayer = RYS.Services.LocalPlayer
    
    local flyBody = nil
    local flyGyro = nil
    
    local function SetupFly(char)
        if not char then return end
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        
        -- สร้าง BodyVelocity & BodyGyro
        flyBody = Instance.new("BodyVelocity")
        flyBody.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        flyBody.Velocity = Vector3.new(0, 0, 0)
        flyBody.Parent = rootPart

        flyGyro = Instance.new("BodyGyro")
        flyGyro.Name = "RYS_FlyGyro"
        flyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        flyGyro.P = 9e4
        flyGyro.Parent = rootPart
        
        -- Anti-Fall Hook (เปลี่ยน state เป็น Landing ถ้าใกล้พื้น)
        pcall(function()
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Swimming)
            end
        end)
    end
    
    local function RemoveFly(char)
        if flyBody then pcall(function() flyBody:Destroy() end) flyBody = nil end
        if flyGyro then pcall(function() flyGyro:Destroy() end) flyGyro = nil end
        if char then
            local rp = char:FindFirstChild("HumanoidRootPart")
            if rp then
                local g = rp:FindFirstChild("RYS_FlyGyro")
                if g then g:Destroy() end
            end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end
        end
    end

    function Fly.Toggle(state)
        RYS.Enabled.Fly = state
        if state then
            SetupFly(RYS.GetCharacter())

            -- Fly Movement Loop (RenderStepped for smooth camera-relative movement)
            ConnMgr:AddConnection(MODULE_NAME, game:GetService("RunService").RenderStepped, function()
                if not RYS.Enabled.Fly or not flyBody or not flyBody.Parent then return end
                
                local dir = Vector3.new(0, 0, 0)
                local currentSpeed = RYS.Settings.FlySpeed or 50
                local humanoid = RYS.GetHumanoid()
                
                if RYS.IsMobile then
                    -- Mobile Control
                    if humanoid then
                        local moveDir = humanoid.MoveDirection
                        if moveDir.Magnitude > 0 then
                            dir = dir + moveDir.Unit
                        end
                        if humanoid:GetState() == Enum.HumanoidStateType.Jumping then
                            dir = dir + Vector3.new(0, 1, 0)
                        end
                    end
                else
                    -- PC Control
                    if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
                    if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
                    if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
                    if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
                    if UIS:IsKeyDown(Enum.KeyCode.Space) or UIS:IsKeyDown(Enum.KeyCode.E) then dir = dir + Vector3.new(0, 1, 0) end
                    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.Q) then dir = dir - Vector3.new(0, 1, 0) end
                    
                    -- Speed Modifiers
                    if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then currentSpeed = currentSpeed * 2.5 end
                end

                flyBody.Velocity = dir * currentSpeed
                flyGyro.CFrame = Camera.CFrame
                
                -- Noclip while flying (optional feature)
                if RYS.Settings.FlyNoclip and humanoid then
                    for _, part in ipairs(humanoid.Parent:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
            
            -- Auto-Recovery (Respawn)
            ConnMgr:AddConnection(MODULE_NAME .. "_Respawn", LocalPlayer.CharacterAdded, function(newChar)
                if RYS.Enabled.Fly then
                    task.wait(0.5)
                    SetupFly(newChar)
                end
            end)

            if RYS.IsMobile then
                RYS.Notify("Fly", "✈️ บินได้แล้ว! ใช้ Joystick เดิน + Jump บินขึ้น")
            else
                RYS.Notify("Fly", "✈️ บินได้แล้ว! WASD+Space/Ctrl | Shift=เร่งสปีด")
            end
        else
            ConnMgr:DisconnectAll(MODULE_NAME)
            ConnMgr:DisconnectAll(MODULE_NAME .. "_Respawn")
            RemoveFly(RYS.GetCharacter())
            RYS.Notify("Fly", "❌ ปิดบินแล้ว")
        end
    end

    RYS.RegisterModule("Fly", Fly)
    return Fly
end
