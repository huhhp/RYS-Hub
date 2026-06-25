--[[
    RYS Hub — Freecam Module
--]]

return function(RYS, ConnMgr)
    local Freecam = {}
    local UIS = RYS.Services.UserInputService
    local Camera = RYS.Services.Camera
    local MODULE_NAME = "Freecam"
    local freecamCF = nil

    function Freecam.Toggle(state)
        RYS.Enabled.Freecam = state
        if state then
            freecamCF = Camera.CFrame
            -- Freecam ต้อง RenderStepped จริง (camera movement)
            ConnMgr:AddConnection(MODULE_NAME, game:GetService("RunService").RenderStepped, function()
                if not RYS.Enabled.Freecam then return end
                local speed = RYS.Settings.FreecamSpeed
                local dir = Vector3.new(0, 0, 0)

                if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + freecamCF.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - freecamCF.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - freecamCF.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + freecamCF.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.E) then dir = dir + Vector3.new(0, 1, 0) end
                if UIS:IsKeyDown(Enum.KeyCode.Q) then dir = dir - Vector3.new(0, 1, 0) end

                if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then speed = speed * 3 end

                freecamCF = freecamCF + dir * speed
                Camera.CameraType = Enum.CameraType.Scriptable
                Camera.CFrame = freecamCF
            end)
            RYS.Notify("Freecam", "✅ บินกล้องอิสระ! WASD+QE")
        else
            ConnMgr:DisconnectAll(MODULE_NAME)
            Camera.CameraType = Enum.CameraType.Custom
            RYS.Notify("Freecam", "❌ ปิดแล้ว")
        end
    end

    RYS.RegisterModule("Freecam", Freecam)
    return Freecam
end
