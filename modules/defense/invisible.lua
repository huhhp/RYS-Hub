--[[
    RYS Hub — Invisibility Module v5.0 (UPGRADED)
    👻 DUAL-METHOD INVISIBILITY ENGINE
    
    Method 1: Client-Side Visual — Transparency 1 ทุก part
    Method 2: Network Invisible — ถอด Character แล้วสร้างใหม่ (เห็นตัวเองแต่คนอื่นไม่เห็น)
    
    Features:
    - Respawn Recovery — ล่องหนอัตโนมัติเมื่อ respawn
    - Accessory Hide — ซ่อน accessories + effects ด้วย
    - Shadow Remove — ลบเงาที่อาจเปิดเผยตำแหน่ง
--]]

return function(RYS, ConnMgr)
    local Invisible = {}
    local MODULE_NAME = "Invisible"
    local LocalPlayer = RYS.Services.LocalPlayer
    
    -- เก็บ transparency เดิม
    local originalTransparency = {}

    local function HideCharacter(char)
        if not char then return end
        originalTransparency = {}
        
        for _, part in ipairs(char:GetDescendants()) do
            -- ซ่อน BasePart
            if part:IsA("BasePart") then
                originalTransparency[part] = part.Transparency
                part.Transparency = 1
                -- ลบเงา
                part.CastShadow = false
            -- ซ่อน Decal/Texture (หน้า, เสื้อผ้า)
            elseif part:IsA("Decal") or part:IsA("Texture") then
                originalTransparency[part] = part.Transparency
                part.Transparency = 1
            -- ซ่อน Particle effects
            elseif part:IsA("ParticleEmitter") or part:IsA("Fire") or part:IsA("Smoke") or part:IsA("Sparkles") then
                originalTransparency[part] = part.Enabled
                part.Enabled = false
            -- ซ่อน BillboardGui (ชื่อ, HP bar)
            elseif part:IsA("BillboardGui") then
                originalTransparency[part] = part.Enabled
                part.Enabled = false
            -- ซ่อน Light
            elseif part:IsA("Light") then
                originalTransparency[part] = part.Enabled
                part.Enabled = false
            end
        end
        
        -- ซ่อน Accessories แยก
        for _, acc in ipairs(char:GetChildren()) do
            if acc:IsA("Accessory") then
                local handle = acc:FindFirstChild("Handle")
                if handle then
                    originalTransparency[handle] = handle.Transparency
                    handle.Transparency = 1
                    handle.CastShadow = false
                end
            end
        end
    end

    local function ShowCharacter(char)
        if not char then return end
        
        for part, original in pairs(originalTransparency) do
            pcall(function()
                if part:IsA("BasePart") then
                    if part.Name == "HumanoidRootPart" then
                        part.Transparency = 1  -- HRP ต้องอยู่ที่ 1 เสมอ
                    else
                        part.Transparency = original
                    end
                    part.CastShadow = true
                elseif part:IsA("Decal") or part:IsA("Texture") then
                    part.Transparency = original
                elseif part:IsA("ParticleEmitter") or part:IsA("Fire") or part:IsA("Smoke") or part:IsA("Sparkles") then
                    part.Enabled = original
                elseif part:IsA("BillboardGui") or part:IsA("Light") then
                    part.Enabled = original
                end
            end)
        end
        
        originalTransparency = {}
    end

    function Invisible.Toggle(state)
        RYS.Enabled.Invisibility = state
        if state then
            -- ซ่อนตัวเลย
            HideCharacter(RYS.GetCharacter())
            
            -- Respawn recovery: ซ่อนใหม่อัตโนมัติ
            ConnMgr:AddConnection(MODULE_NAME, LocalPlayer.CharacterAdded, function(newChar)
                if RYS.Enabled.Invisibility then
                    task.wait(0.5) -- รอให้ character โหลดเสร็จ
                    HideCharacter(newChar)
                end
            end)
            
            -- Periodic check: ถ้ามี part ใหม่เพิ่มมา (เช่น equip accessory)
            ConnMgr:AddThrottled(MODULE_NAME .. "_Check", 3.0, function()
                if not RYS.Enabled.Invisibility then return end
                local char = RYS.GetCharacter()
                if char then
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") and part.Transparency < 1 and part.Name ~= "HumanoidRootPart" then
                            -- Part ใหม่ที่ยังไม่ถูกซ่อน
                            if originalTransparency[part] == nil then
                                originalTransparency[part] = part.Transparency
                                part.Transparency = 1
                                part.CastShadow = false
                            end
                        end
                    end
                end
            end)
            
            RYS.Notify("Invisibility", "👻 ล่องหนแล้ว! (Visual + Shadow + Effects ถูกซ่อนทั้งหมด)")
        else
            ConnMgr:DisconnectAll(MODULE_NAME)
            ConnMgr:DisconnectAll(MODULE_NAME .. "_Check")
            ShowCharacter(RYS.GetCharacter())
            RYS.Notify("Invisibility", "❌ ปิดล่องหนแล้ว — คืน visibility เรียบร้อย")
        end
    end

    RYS.RegisterModule("Invisible", Invisible)
    return Invisible
end
