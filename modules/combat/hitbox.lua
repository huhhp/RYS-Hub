--[[
    RYS Hub — Hitbox Expander v5.0 (UPGRADED)
    🎯 ADVANCED HITBOX ENGINE
    
    Features:
    1. Team Check — ไม่ขยายกล่องเพื่อนร่วมทีม
    2. Head-Only Mode — ขยายเฉพาะหัวสำหรับ Aimbot
    3. Visual Indicator — เลือกว่าจะให้เห็นกล่องแดงหรือไม่
    4. Part Choice — เลือกส่วนที่ขยายได้ (Root, Head, Torso)
--]]

return function(RYS, ConnMgr)
    local Hitbox = {}
    local Players = RYS.Services.Players
    local LocalPlayer = RYS.Services.LocalPlayer
    local MODULE_NAME = "Hitbox"
    
    -- เก็บ size เดิม
    local originalSizes = {}

    local function IsEnemy(player)
        if player == LocalPlayer then return false end
        if RYS.Settings.TeamCheck and LocalPlayer.Team and player.Team then
            return player.Team ~= LocalPlayer.Team
        end
        return true
    end

    function Hitbox.Toggle(state)
        RYS.Enabled.HitboxExpander = state
        if state then
            -- ใช้ Throttle 0.2s เพื่อประหยัด CPU (Hitbox ไม่ต้องอัพเดททุกเฟรม)
            ConnMgr:AddThrottled(MODULE_NAME, 0.2, function()
                if not RYS.Enabled.HitboxExpander then return end
                
                local size = RYS.Settings.HitboxSize or 5
                local targetPartName = RYS.Settings.HitboxPart or "HumanoidRootPart" -- "Head" ก็ได้
                
                for _, player in ipairs(Players:GetPlayers()) do
                    if IsEnemy(player) and player.Character then
                        local targetPart = player.Character:FindFirstChild(targetPartName)
                        if targetPart then
                            -- บันทึกค่าเดิม
                            if not originalSizes[player.Name] then
                                originalSizes[player.Name] = targetPart.Size
                            end
                            
                            targetPart.Size = Vector3.new(size, size, size)
                            targetPart.CanCollide = false
                            
                            if RYS.Settings.HitboxVisible then
                                targetPart.Transparency = 0.7
                                targetPart.BrickColor = BrickColor.new("Really red")
                                targetPart.Material = Enum.Material.ForceField
                            else
                                targetPart.Transparency = 1
                            end
                        end
                    end
                end
            end)
            RYS.Notify("Hitbox", "🎯 ขยาย Hitbox: " .. (RYS.Settings.HitboxSize or 5) .. " (" .. (RYS.Settings.HitboxPart or "Root") .. ")")
        else
            ConnMgr:DisconnectAll(MODULE_NAME)
            
            -- คืนค่าเดิม
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character then
                    local targetPart = player.Character:FindFirstChild(RYS.Settings.HitboxPart or "HumanoidRootPart")
                    if targetPart and originalSizes[player.Name] then
                        targetPart.Size = originalSizes[player.Name]
                        targetPart.Transparency = 1
                        targetPart.Material = Enum.Material.Plastic
                    end
                end
            end
            originalSizes = {}
            RYS.Notify("Hitbox", "❌ ปิดแล้ว — คืนค่า Hitbox ปกติ")
        end
    end

    RYS.RegisterModule("Hitbox", Hitbox)
    return Hitbox
end
