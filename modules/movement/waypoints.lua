--[[
    RYS Hub — Teleport Waypoints System v5.0
    
    Features:
    1. เซฟพิกัดลง Config ทันที
    2. โหลดพิกัดกลับมาเมื่อเปิดเกมใหม่
    3. GUI สำหรับเพิ่ม/ลบ และวาร์ป
--]]

return function(RYS, ConnMgr)
    local Waypoints = {}
    local MODULE_NAME = "Waypoints"
    
    local Players = RYS.Services.Players
    
    -- Initialize State
    if type(RYS.Settings.Waypoints) ~= "table" then
        RYS.Settings.Waypoints = {} -- Format: { ["FarmZone1"] = CFrame }
    end

    function Waypoints.SavePosition(name)
        local rootPart = RYS.GetRootPart()
        if not rootPart then
            RYS.Notify("Waypoints", "❌ ไม่พบตัวละครของคุณ", 3)
            return false
        end
        
        RYS.Settings.Waypoints[name] = rootPart.CFrame
        
        -- Save ลงไฟล์
        if RYS.Modules.Config then
            pcall(function() RYS.Modules.Config.Save(true) end)
        end
        
        RYS.Notify("Waypoints", "📍 บันทึกพิกัด '" .. name .. "' แล้ว!", 3)
        return true
    end

    function Waypoints.TeleportTo(name)
        local cf = RYS.Settings.Waypoints[name]
        if not cf then
            RYS.Notify("Waypoints Error", "⚠️ ไม่พบพิกัดนี้", 3)
            return false
        end
        
        local rootPart = RYS.GetRootPart()
        if rootPart then
            -- เช็คว่ามีเกมแบนวาร์ปไหม ถ้ามีอาจจะต้อง bypass ด้วย Tween (ในอนาคต)
            -- ตอนนี้ใช้วิธี CFrame ตรงๆ 
            rootPart.CFrame = cf
            RYS.Notify("Waypoints", "วาร์ปไปที่ '" .. name .. "'", 2)
            return true
        end
        return false
    end

    function Waypoints.Delete(name)
        if RYS.Settings.Waypoints[name] then
            RYS.Settings.Waypoints[name] = nil
            
            if RYS.Modules.Config then
                pcall(function() RYS.Modules.Config.Save(true) end)
            end
            RYS.Notify("Waypoints", "🗑️ ลบพิกัด '" .. name .. "' แล้ว", 2)
            return true
        end
        return false
    end
    
    function Waypoints.GetList()
        local list = {}
        for name, _ in pairs(RYS.Settings.Waypoints) do
            table.insert(list, name)
        end
        table.sort(list)
        return list
    end

    RYS.RegisterModule("Waypoints", Waypoints)
    return Waypoints
end
