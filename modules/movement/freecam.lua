--[[
    RYS Hub — Freecam Module v5.0 (UPGRADED)
    📹 ADVANCED FREE CAMERA ENGINE
    
    Features:
    1. WASD + QE movement (เดิม)
    2. Variable speed (Shift = turbo, Ctrl = slow)
    3. Mouse rotation control (คลิกขวาค้างเพื่อหมุนกล้อง)
    4. TP to Camera — Teleport ตัวละครไปตำแหน่งกล้องเมื่อปิด
    5. Freeze Character — ตรึงตัวละครไว้ตอนใช้ freecam
    6. Smooth interpolation — ขยับกล้องแบบ smooth
--]]

return function(RYS, ConnMgr)
    local Freecam = {}
    local MODULE_NAME = "Freecam"
    local UIS = RYS.Services.UserInputService
    local Camera = RYS.Services.Camera
    local RunService = game:GetService("RunService")
    
    local freecamCF = nil
    local originalCamType = nil
    local frozenCF = nil

    function Freecam.Toggle(state)
        RYS.Enabled.Freecam = state
        if state then
            -- เก็บค่าเดิม
            originalCamType = Camera.CameraType
            freecamCF = Camera.CFrame
            
            -- Freeze character
            local root = RYS.GetRootPart()
            if root then
                frozenCF = root.CFrame
                pcall(function() root.Anchored = true end)
            end
            
            -- Camera control loop (ต้อง RenderStepped จริงสำหรับ camera)
            ConnMgr:AddConnection(MODULE_NAME, RunService.RenderStepped, function(dt)
                if not RYS.Enabled.Freecam then return end
                
                local baseSpeed = RYS.Settings.FreecamSpeed
                local speed = baseSpeed
                local dir = Vector3.new(0, 0, 0)

                -- Speed modifiers
                if not RYS.IsMobile then
                    if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then speed = speed * 4 end  -- Turbo
                    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then speed = speed * 0.25 end  -- Slow
                end

                -- Direction input
                if not RYS.IsMobile then
                    if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + freecamCF.LookVector end
                    if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - freecamCF.LookVector end
                    if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - freecamCF.RightVector end
                    if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + freecamCF.RightVector end
                    if UIS:IsKeyDown(Enum.KeyCode.E) then dir = dir + Vector3.new(0, 1, 0) end
                    if UIS:IsKeyDown(Enum.KeyCode.Q) then dir = dir - Vector3.new(0, 1, 0) end
                else
                    -- Mobile: ใช้ MoveDirection จาก Humanoid
                    local hum = RYS.GetHumanoid()
                    if hum then
                        local moveDir = hum.MoveDirection
                        if moveDir.Magnitude > 0 then
                            dir = dir + moveDir
                        end
                    end
                end

                -- Smooth interpolation (lerp)
                if dir.Magnitude > 0 then
                    local targetPos = freecamCF.Position + (dir.Unit * speed * dt * 60)
                    local lerpedPos = freecamCF.Position:Lerp(targetPos, 0.5)
                    freecamCF = CFrame.new(lerpedPos) * (freecamCF - freecamCF.Position)
                end
                
                Camera.CameraType = Enum.CameraType.Scriptable
                Camera.CFrame = freecamCF
            end)
            
            -- Mouse rotation (right-click drag)
            if not RYS.IsMobile then
                ConnMgr:AddConnection(MODULE_NAME .. "_Mouse", UIS.InputChanged, function(input)
                    if not RYS.Enabled.Freecam then return end
                    if input.UserInputType == Enum.UserInputType.MouseMovement and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                        local delta = input.Delta
                        local sensitivity = 0.003
                        freecamCF = freecamCF * CFrame.Angles(-delta.Y * sensitivity, -delta.X * sensitivity, 0)
                    end
                end)
            end
            
            RYS.Notify("Freecam", "📹 กล้องอิสระ! WASD+QE | Shift=เร็ว Ctrl=ช้า | คลิกขวาหมุน")
        else
            ConnMgr:DisconnectAll(MODULE_NAME)
            ConnMgr:DisconnectAll(MODULE_NAME .. "_Mouse")
            
            -- คืน camera
            Camera.CameraType = originalCamType or Enum.CameraType.Custom
            
            -- Unfreeze + TP to camera option
            local root = RYS.GetRootPart()
            if root then
                pcall(function() root.Anchored = false end)
                -- Teleport ตัวละครไปตำแหน่งกล้องสุดท้าย
                if freecamCF then
                    pcall(function()
                        root.CFrame = CFrame.new(freecamCF.Position) * CFrame.Angles(0, select(2, freecamCF:ToEulerAnglesYXZ()), 0)
                    end)
                end
            end
            
            RYS.Notify("Freecam", "❌ ปิดแล้ว — TP ตัวละครไปตำแหน่งกล้อง")
        end
    end

    RYS.RegisterModule("Freecam", Freecam)
    return Freecam
end
