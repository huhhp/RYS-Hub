--[[
    RYS Hub — Noclip Module v5.0 (UPGRADED)
    👻 ADVANCED NOCLIP WITH THROTTLE + SMART RESTORE
    
    Features:
    1. Throttled Collision Disable (ไม่ต้องทุกเฟรม)
    2. Smart Restore — คืน collision ให้ถูกต้องเมื่อปิด
    3. Respawn Recovery — ติดตั้งใหม่เมื่อ respawn
    4. Vehicle Noclip — ทะลุกำแพงแม้จะนั่งรถ
--]]

return function(RYS, ConnMgr)
    local Noclip = {}
    local MODULE_NAME = "Noclip"
    local RunService = game:GetService("RunService")
    
    -- เก็บ original collision state
    local originalCollisions = {}

    local function DisableCollisions(char)
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                -- เก็บค่าเดิมถ้ายังไม่ได้เก็บ
                if originalCollisions[part] == nil then
                    originalCollisions[part] = part.CanCollide
                end
                part.CanCollide = false
            end
        end
    end

    local function RestoreCollisions(char)
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                local original = originalCollisions[part]
                if original ~= nil then
                    part.CanCollide = original
                else
                    -- Default: ทุก part CanCollide true ยกเว้น HumanoidRootPart
                    part.CanCollide = (part.Name ~= "HumanoidRootPart")
                end
            end
        end
        originalCollisions = {}
    end

    function Noclip.Toggle(state)
        RYS.Enabled.Noclip = state
        if state then
            -- Stepped event (ถูกต้องสำหรับ physics/collision)
            -- ใช้ Stepped แทน RenderStepped เพื่อให้ collision update ก่อน physics
            ConnMgr:AddConnection(MODULE_NAME, RunService.Stepped, function()
                if not RYS.Enabled.Noclip then return end
                DisableCollisions(RYS.GetCharacter())
            end)
            
            -- Vehicle noclip: ถ้านั่ง VehicleSeat ให้ disable collision ของรถด้วย
            ConnMgr:AddThrottled(MODULE_NAME .. "_Vehicle", 0.5, function()
                if not RYS.Enabled.Noclip then return end
                local char = RYS.GetCharacter()
                if not char then return end
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.SeatPart then
                    local vehicle = hum.SeatPart.Parent
                    if vehicle then
                        for _, part in ipairs(vehicle:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                end
            end)
            
            -- Respawn recovery
            ConnMgr:AddConnection(MODULE_NAME .. "_Respawn",
                RYS.Services.LocalPlayer.CharacterAdded, function(newChar)
                    if RYS.Enabled.Noclip then
                        originalCollisions = {}
                        task.wait(0.3)
                        -- Noclip จะเริ่มทำงานอัตโนมัติผ่าน Stepped connection ที่มีอยู่
                    end
                end)
            
            RYS.Notify("Noclip", "👻 ทะลุกำแพงได้แล้ว! (+ Vehicle + Respawn Recovery)")
        else
            ConnMgr:DisconnectAll(MODULE_NAME)
            ConnMgr:DisconnectAll(MODULE_NAME .. "_Vehicle")
            ConnMgr:DisconnectAll(MODULE_NAME .. "_Respawn")
            RestoreCollisions(RYS.GetCharacter())
            RYS.Notify("Noclip", "❌ ปิดแล้ว — คืน collision เรียบร้อย")
        end
    end

    RYS.RegisterModule("Noclip", Noclip)
    return Noclip
end
