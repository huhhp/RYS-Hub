--[[
    RYS Hub — Config Engine v5.0
    
    Features:
    1. Save/Load Settings & States อัตโนมัติ
    2. Serialization รองรับ Color3, Vector3, CFrame, Enum, UDim2
    3. บันทึกลง Local File System (RYS_Config/settings.json)
--]]

return function(RYS, ConnMgr)
    local Config = {}
    local MODULE_NAME = "Config"
    
    local HttpService = RYS.Services.ReplicatedStorage:GetService("HttpService") -- ใช้จากต้นทางถ้ามี
    if not pcall(function() HttpService = game:GetService("HttpService") end) then
        HttpService = game:GetService("HttpService")
    end
    
    local CONFIG_FOLDER = "RYS_Config"
    local CONFIG_FILE = CONFIG_FOLDER .. "/settings.json"
    
    -- ═══════════════════════════════════════
    -- SERIALIZER (Encode/Decode data types)
    -- ═══════════════════════════════════════
    local function SerializeData(data)
        if type(data) == "table" then
            local result = {}
            for k, v in pairs(data) do
                result[k] = SerializeData(v)
            end
            return result
        elseif typeof(data) == "Color3" then
            return { __type = "Color3", R = data.R, G = data.G, B = data.B }
        elseif typeof(data) == "Vector3" then
            return { __type = "Vector3", X = data.X, Y = data.Y, Z = data.Z }
        elseif typeof(data) == "CFrame" then
            return { __type = "CFrame", components = {data:GetComponents()} }
        elseif typeof(data) == "EnumItem" then
            return { __type = "EnumItem", Value = tostring(data) }
        elseif typeof(data) == "UDim2" then
            return { __type = "UDim2", xScale = data.X.Scale, xOffset = data.X.Offset, yScale = data.Y.Scale, yOffset = data.Y.Offset }
        elseif typeof(data) == "KeyCode" then
            return { __type = "KeyCode", Value = data.Name }
        else
            return data -- string, number, boolean
        end
    end
    
    local function DeserializeData(data)
        if type(data) == "table" then
            if data.__type == "Color3" then
                return Color3.new(data.R, data.G, data.B)
            elseif data.__type == "Vector3" then
                return Vector3.new(data.X, data.Y, data.Z)
            elseif data.__type == "CFrame" then
                return CFrame.new(unpack(data.components))
            elseif data.__type == "EnumItem" then
                local parts = string.split(data.Value, ".")
                if #parts == 3 then
                    return Enum[parts[2]][parts[3]]
                end
                return data.Value
            elseif data.__type == "KeyCode" then
                return Enum.KeyCode[data.Value]
            elseif data.__type == "UDim2" then
                return UDim2.new(data.xScale, data.xOffset, data.yScale, data.yOffset)
            else
                local result = {}
                for k, v in pairs(data) do
                    result[k] = DeserializeData(v)
                end
                return result
            end
        else
            return data
        end
    end

    -- ═══════════════════════════════════════
    -- CORE FUNCTIONS
    -- ═══════════════════════════════════════
    local function EnsureFolder()
        if makefolder and not isfolder(CONFIG_FOLDER) then
            pcall(makefolder, CONFIG_FOLDER)
        end
    end

    function Config.Save(silent)
        EnsureFolder()
        
        local payload = {
            Version = RYS.Version,
            Enabled = SerializeData(RYS.Enabled),
            Settings = SerializeData(RYS.Settings),
            -- Theme, Profiles and Keybinds จะถูกบันทึกผ่านระบบของมันเองหรือรวมที่นี่ได้
            -- ถ้ามี RYS.Keybinds ก็เซฟด้วย
            Keybinds = RYS.Keybinds and SerializeData(RYS.Keybinds) or {}
        }
        
        local success, json = pcall(function() return HttpService:JSONEncode(payload) end)
        if success and json then
            local written, err = RYS.FS.Write(CONFIG_FILE, json)
            if written and not silent then
                RYS.Notify("Config", "💾 บันทึกการตั้งค่าสำเร็จ!")
            elseif not written and not silent then
                RYS.Notify("Config Error", "❌ ไม่สามารถบันทึกได้: " .. tostring(err))
            end
            return written
        end
        return false
    end

    function Config.Load(silent)
        EnsureFolder()
        
        if not RYS.FS.Exists(CONFIG_FILE) then
            if not silent then RYS.Notify("Config", "⚠️ ไม่พบไฟล์ตั้งค่า จะใช้ค่าเริ่มต้น") end
            return false
        end
        
        local content = RYS.FS.Read(CONFIG_FILE)
        if not content then return false end
        
        local success, decoded = pcall(function() return HttpService:JSONDecode(content) end)
        if success and type(decoded) == "table" then
            local data = DeserializeData(decoded)
            
            -- Merge Data (เราไม่ overwrite ทั้งตาราง เพื่อรักษา default keys ที่อาจเพิ่มใหม่ในอัปเดต)
            if data.Enabled and type(data.Enabled) == "table" then
                for k, v in pairs(data.Enabled) do
                    RYS.Enabled[k] = v
                end
            end
            
            if data.Settings and type(data.Settings) == "table" then
                for k, v in pairs(data.Settings) do
                    RYS.Settings[k] = v
                end
            end
            
            if data.Keybinds and type(data.Keybinds) == "table" then
                if not RYS.Keybinds then RYS.Keybinds = {} end
                for k, v in pairs(data.Keybinds) do
                    RYS.Keybinds[k] = v
                end
            end
            
            if not silent then
                RYS.Notify("Config", "📥 โหลดการตั้งค่าสำเร็จ! (v" .. tostring(data.Version or "Unknown") .. ")")
            end
            
            -- รีเฟรชสถานะ Module
            -- (อันนี้จะทำหลังจากสร้าง GUI แล้วให้ toggle อัปเดตตัวเอง)
            
            return true
        else
            if not silent then RYS.Notify("Config Error", "❌ ไฟล์การตั้งค่าเสียหายหรืออ่านไม่ได้") end
        end
        return false
    end

    function Config.Delete()
        if RYS.FS.Exists(CONFIG_FILE) then
            RYS.FS.Delete(CONFIG_FILE)
            RYS.Notify("Config", "🗑️ ลบไฟล์ตั้งค่าแล้ว")
        end
    end

    -- Auto-save loop (every 3 minutes)
    ConnMgr:AddThrottled(MODULE_NAME, 180, function()
        if RYS.Settings.AutoSave then
            Config.Save(true) -- silent save
        end
    end)

    RYS.RegisterModule("Config", Config)
    return Config
end
