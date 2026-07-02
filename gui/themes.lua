--[[
    RYS Hub — Theme Engine v5.0
    
    Features:
    1. จัดการ Color Palettes หลายรูปแบบ (Violet, Crimson, Neon Matrix, Gold)
    2. API สำหรับให้ GUI Components ดูดสีแบบ Real-time
--]]

return function(RYS, ConnMgr)
    local Themes = {}
    
    -- กำหนดชุดสีทั้งหมด
    Themes.Palettes = {
        ["Electric Violet (Default)"] = {
            Background = Color3.fromRGB(15, 12, 28),
            Sidebar = Color3.fromRGB(11, 8, 22),
            Primary = Color3.fromRGB(138, 43, 226),
            Secondary = Color3.fromRGB(60, 48, 90),
            Accent1 = Color3.fromRGB(0, 255, 255),
            Accent2 = Color3.fromRGB(110, 50, 200),
            Text = Color3.fromRGB(220, 200, 255),
            TextDark = Color3.fromRGB(150, 140, 170),
            Success = Color3.fromRGB(0, 255, 200),
            Error = Color3.fromRGB(255, 60, 90)
        },
        ["Crimson Blood"] = {
            Background = Color3.fromRGB(28, 12, 12),
            Sidebar = Color3.fromRGB(22, 8, 8),
            Primary = Color3.fromRGB(226, 43, 43),
            Secondary = Color3.fromRGB(90, 48, 48),
            Accent1 = Color3.fromRGB(255, 150, 0),
            Accent2 = Color3.fromRGB(200, 50, 50),
            Text = Color3.fromRGB(255, 200, 200),
            TextDark = Color3.fromRGB(170, 140, 140),
            Success = Color3.fromRGB(255, 200, 0),
            Error = Color3.fromRGB(255, 60, 90)
        },
        ["Neon Matrix"] = {
            Background = Color3.fromRGB(10, 25, 15),
            Sidebar = Color3.fromRGB(5, 18, 10),
            Primary = Color3.fromRGB(0, 255, 100),
            Secondary = Color3.fromRGB(30, 90, 50),
            Accent1 = Color3.fromRGB(0, 255, 200),
            Accent2 = Color3.fromRGB(0, 200, 80),
            Text = Color3.fromRGB(200, 255, 220),
            TextDark = Color3.fromRGB(120, 170, 140),
            Success = Color3.fromRGB(0, 255, 100),
            Error = Color3.fromRGB(255, 80, 80)
        },
        ["Gold Luxury"] = {
            Background = Color3.fromRGB(25, 25, 20),
            Sidebar = Color3.fromRGB(18, 18, 15),
            Primary = Color3.fromRGB(255, 215, 0),
            Secondary = Color3.fromRGB(100, 90, 30),
            Accent1 = Color3.fromRGB(255, 255, 255),
            Accent2 = Color3.fromRGB(200, 170, 0),
            Text = Color3.fromRGB(255, 245, 200),
            TextDark = Color3.fromRGB(180, 170, 140),
            Success = Color3.fromRGB(0, 255, 100),
            Error = Color3.fromRGB(255, 80, 80)
        }
    }
    
    -- ตั้งค่าเริ่มต้นถ้าไม่มี
    if not RYS.Settings.ActiveTheme or not Themes.Palettes[RYS.Settings.ActiveTheme] then
        RYS.Settings.ActiveTheme = "Electric Violet (Default)"
    end

    -- Signal Event เมื่อ Theme เปลี่ยน (แบบพื้นฐาน)
    Themes.OnThemeChanged = Instance.new("BindableEvent")

    -- ═══════════════════════════════════════
    -- CORE FUNCTIONS
    -- ═══════════════════════════════════════
    function Themes.SetTheme(themeName)
        if Themes.Palettes[themeName] then
            RYS.Settings.ActiveTheme = themeName
            Themes.OnThemeChanged:Fire(Themes.Palettes[themeName])
            
            if RYS.Modules.Config then
                pcall(function() RYS.Modules.Config.Save(true) end)
            end
            
            -- บังคับรีเฟรชหน้าต่าง (ถ้าต้องการแบบ Hard Refresh เราอาจจะต้องสร้าง GUI ใหม่, 
            -- แต่เราจะให้ BindableEvent อัปเดตสีเฉพาะจุดที่เปลี่ยนได้)
            -- 
            -- เพื่อความเนียนในการอัปเดตแบบ Dynamic เราจะต้องเขียน Components ให้ดักจับ OnThemeChanged
            -- (เดี๋ยวผมจะแก้ components.lua ให้ซิงค์เองทีหลัง)
        end
    end

    function Themes.GetColor(colorKey)
        local theme = Themes.Palettes[RYS.Settings.ActiveTheme] or Themes.Palettes["Electric Violet (Default)"]
        return theme[colorKey] or Color3.new(1,1,1)
    end

    function Themes.GetThemeList()
        local list = {}
        for name, _ in pairs(Themes.Palettes) do
            table.insert(list, name)
        end
        return list
    end

    RYS.RegisterModule("Themes", Themes)
    return Themes
end
