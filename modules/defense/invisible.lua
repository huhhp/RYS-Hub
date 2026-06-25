--[[
    RYS Hub — Invisibility Module
--]]

return function(RYS, ConnMgr)
    local Invisible = {}
    local MODULE_NAME = "Invisible"

    function Invisible.Toggle(state)
        RYS.Enabled.Invisibility = state
        if state then
            local char = RYS.GetCharacter()
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Transparency = 1
                    elseif part:IsA("Decal") or part:IsA("Texture") then
                        part.Transparency = 1
                    end
                end
                local face = char:FindFirstChild("Head") and char.Head:FindFirstChildOfClass("Decal")
                if face then face.Transparency = 1 end
            end
            RYS.Notify("Invisibility", "✅ ล่องหนแล้ว!")
        else
            local char = RYS.GetCharacter()
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.Transparency = 0
                    elseif part:IsA("Decal") or part:IsA("Texture") then
                        part.Transparency = 0
                    end
                end
            end
            RYS.Notify("Invisibility", "❌ ปิดล่องหนแล้ว")
        end
    end

    RYS.RegisterModule("Invisible", Invisible)
    return Invisible
end
