--[[
    RYS Hub — Profiles System v5.0
    
    Features:
    1. สร้าง ลบ และโหลดโปรไฟล์การตั้งค่า (Presets)
    2. จัดเก็บแยกลงโฟลเดอร์ RYS_Config/profiles/
--]]

return function(RYS, ConnMgr)
    local Profiles = {}
    local MODULE_NAME = "Profiles"
    
    local HttpService = RYS.Services.ReplicatedStorage:GetService("HttpService")
    if not pcall(function() HttpService = game:GetService("HttpService") end) then
        HttpService = game:GetService("HttpService")
    end
    
    local PROFILES_FOLDER = "RYS_Config/profiles"
    
    local function EnsureFolder()
        if makefolder then
            if not isfolder("RYS_Config") then pcall(makefolder, "RYS_Config") end
            if not isfolder(PROFILES_FOLDER) then pcall(makefolder, PROFILES_FOLDER) end
        end
    end
    
    -- ใช้ Serializer ตัวเดียวกับ Config
    local SerializeData = nil
    local DeserializeData = nil
    
    -- Hacky way to grab serializer functions if they were exposed, 
    -- but since they are local in Config, we will just re-implement the simple version 
    -- or better yet, rely on Config to do the heavy lifting if we inject state temporarily.
    -- To keep it clean, we'll re-implement the Serializer here for Profiles to be standalone.
    
    local function Serialize(data)
        if type(data) == "table" then
            local result = {}
            for k, v in pairs(data) do result[k] = Serialize(v) end
            return result
        elseif typeof(data) == "Color3" then return { __type = "Color3", R = data.R, G = data.G, B = data.B }
        elseif typeof(data) == "Vector3" then return { __type = "Vector3", X = data.X, Y = data.Y, Z = data.Z }
        elseif typeof(data) == "CFrame" then return { __type = "CFrame", components = {data:GetComponents()} }
        elseif typeof(data) == "EnumItem" then return { __type = "EnumItem", Value = tostring(data) }
        elseif typeof(data) == "KeyCode" then return { __type = "KeyCode", Value = data.Name }
        elseif typeof(data) == "UDim2" then return { __type = "UDim2", xScale = data.X.Scale, xOffset = data.X.Offset, yScale = data.Y.Scale, yOffset = data.Y.Offset }
        else return data end
    end
    
    local function Deserialize(data)
        if type(data) == "table" then
            if data.__type == "Color3" then return Color3.new(data.R, data.G, data.B)
            elseif data.__type == "Vector3" then return Vector3.new(data.X, data.Y, data.Z)
            elseif data.__type == "CFrame" then return CFrame.new(unpack(data.components))
            elseif data.__type == "EnumItem" then
                local parts = string.split(data.Value, ".")
                if #parts == 3 then return Enum[parts[2]][parts[3]] end
                return data.Value
            elseif data.__type == "KeyCode" then return Enum.KeyCode[data.Value]
            elseif data.__type == "UDim2" then return UDim2.new(data.xScale, data.xOffset, data.yScale, data.yOffset)
            else
                local result = {}
                for k, v in pairs(data) do result[k] = Deserialize(v) end
                return result
            end
        else return data end
    end

    -- ═══════════════════════════════════════
    -- PROFILE FUNCTIONS
    -- ═══════════════════════════════════════
    function Profiles.SaveProfile(name)
        EnsureFolder()
        local path = PROFILES_FOLDER .. "/" .. name .. ".json"
        
        local payload = {
            ProfileName = name,
            Enabled = Serialize(RYS.Enabled),
            Settings = Serialize(RYS.Settings),
            Keybinds = RYS.Keybinds and Serialize(RYS.Keybinds) or {}
        }
        
        local success, json = pcall(function() return HttpService:JSONEncode(payload) end)
        if success and json then
            local written, err = RYS.FS.Write(path, json)
            if written then
                RYS.Notify("Profiles", "✅ บันทึกโปรไฟล์ '" .. name .. "' สำเร็จ")
                return true
            else
                RYS.Notify("Profiles Error", "❌ บันทึกโปรไฟล์ล้มเหลว: " .. tostring(err))
            end
        end
        return false
    end

    function Profiles.LoadProfile(name)
        local path = PROFILES_FOLDER .. "/" .. name .. ".json"
        if not RYS.FS.Exists(path) then
            RYS.Notify("Profiles Error", "⚠️ ไม่พบโปรไฟล์ชื่อ '" .. name .. "'")
            return false
        end
        
        local content = RYS.FS.Read(path)
        if not content then return false end
        
        local success, decoded = pcall(function() return HttpService:JSONDecode(content) end)
        if success and type(decoded) == "table" then
            local data = Deserialize(decoded)
            
            -- โหลดข้อมูลทับของปัจจุบัน
            if data.Enabled then
                for k, v in pairs(data.Enabled) do RYS.Enabled[k] = v end
            end
            if data.Settings then
                for k, v in pairs(data.Settings) do RYS.Settings[k] = v end
            end
            if data.Keybinds then
                if not RYS.Keybinds then RYS.Keybinds = {} end
                for k, v in pairs(data.Keybinds) do RYS.Keybinds[k] = v end
            end
            
            -- สั่งให้ Config หลักเซฟสถานะใหม่นี้
            if RYS.Modules.Config then
                pcall(function() RYS.Modules.Config.Save(true) end)
            end
            
            RYS.Notify("Profiles", "📥 โหลดโปรไฟล์ '" .. name .. "' สำเร็จแล้ว!")
            return true
        end
        return false
    end

    function Profiles.GetProfilesList()
        EnsureFolder()
        local list = {}
        if listfiles then
            local success, files = pcall(listfiles, PROFILES_FOLDER)
            if success and type(files) == "table" then
                for _, file in ipairs(files) do
                    -- ดึงชื่อไฟล์โดยตัด path และนามสกุลออก
                    local name = file:match("([^/\\]+)%.json$")
                    if name then table.insert(list, name) end
                end
            end
        end
        return list
    end

    function Profiles.DeleteProfile(name)
        local path = PROFILES_FOLDER .. "/" .. name .. ".json"
        if RYS.FS.Exists(path) then
            RYS.FS.Delete(path)
            RYS.Notify("Profiles", "🗑️ ลบโปรไฟล์ '" .. name .. "' แล้ว")
            return true
        end
        return false
    end

    RYS.RegisterModule("Profiles", Profiles)
    return Profiles
end
