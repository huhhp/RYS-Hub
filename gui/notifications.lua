--[[
    RYS Hub — Custom Notification Center v5.0
    
    Features:
    1. Custom UI สำหรับแจ้งเตือน (Glassmorphism, Slide-in Animation)
    2. รองรับข้อความซ้อนกัน (Stack) โดยเลื่อนขึ้นอัตโนมัติ
    3. เลิกใช้ SetCore("SendNotification") แบบเก่า
--]]

return function(RYS, ConnMgr)
    local Notifications = {}
    local MODULE_NAME = "Notifications"
    
    local CoreGui = RYS.Services.CoreGui
    local TweenService = RYS.Services.TweenService
    local RunService = RYS.Services.RunService
    
    local screenGui
    local notificationFrame
    local activeNotifications = {} -- เก็บรายการ UI ที่กำลังแสดง
    
    local MAX_NOTIFICATIONS = 5
    local NOTIF_WIDTH = 250
    local NOTIF_HEIGHT = 60
    local SPACING = 10
    
    -- ═══════════════════════════════════════
    -- SETUP UI
    -- ═══════════════════════════════════════
    local function InitUI()
        pcall(function() CoreGui:FindFirstChild("RYS_Notifications"):Destroy() end)
        
        screenGui = Instance.new("ScreenGui")
        screenGui.Name = "RYS_Notifications"
        screenGui.ResetOnSpawn = false
        RYS.Security.ProtectGui(screenGui)
        
        -- คอนเทนเนอร์หลักสำหรับเก็บแจ้งเตือน ไว้มุมขวาล่าง
        notificationFrame = Instance.new("Frame")
        notificationFrame.Name = "Container"
        notificationFrame.Size = UDim2.new(0, NOTIF_WIDTH, 1, 0)
        notificationFrame.Position = UDim2.new(1, -NOTIF_WIDTH - 20, 0, 0)
        notificationFrame.BackgroundTransparency = 1
        notificationFrame.Parent = screenGui
        
        screenGui.Parent = CoreGui
    end

    -- ═══════════════════════════════════════
    -- CORE FUNCTIONS
    -- ═══════════════════════════════════════
    local function Rearrange()
        -- เรียงตำแหน่งจากล่างขึ้นบน
        local yPos = -20 -- margin ล่างสุด
        
        -- เราจะ loop ย้อนกลับ (อันล่าสุดอยู่ล่างสุด)
        for i = #activeNotifications, 1, -1 do
            local notif = activeNotifications[i]
            if notif and notif.Parent then
                yPos = yPos - NOTIF_HEIGHT - SPACING
                local targetPos = UDim2.new(0, 0, 1, yPos)
                
                -- สร้างแอนิเมชันเลื่อนขึ้น
                TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Position = targetPos
                }):Play()
            end
        end
    end
    
    function Notifications.Notify(title, text, duration, colorKey)
        if not screenGui or not notificationFrame then InitUI() end
        
        duration = duration or 3
        local theme = RYS.Modules.Themes
        local mainColor = theme and theme.GetColor("Primary") or Color3.fromRGB(138, 43, 226)
        local bgColor = theme and theme.GetColor("Background") or Color3.fromRGB(15, 12, 28)
        local textColor = theme and theme.GetColor("Text") or Color3.fromRGB(220, 200, 255)
        
        -- สีตามประเภท (Warning, Error, Info)
        if colorKey == "Error" then mainColor = theme and theme.GetColor("Error") or Color3.fromRGB(255, 60, 90) end
        if colorKey == "Success" then mainColor = theme and theme.GetColor("Success") or Color3.fromRGB(0, 255, 200) end
        
        -- ถ้าเกินลิมิต ให้ลบอันเก่าสุด (อันแรกใน array)
        if #activeNotifications >= MAX_NOTIFICATIONS then
            local oldest = table.remove(activeNotifications, 1)
            if oldest then
                oldest:Destroy()
            end
        end
        
        -- สร้าง UI สำหรับแจ้งเตือนนี้
        local notif = Instance.new("Frame")
        notif.Size = UDim2.new(1, 0, 0, NOTIF_HEIGHT)
        notif.Position = UDim2.new(1, 20, 1, -20 - NOTIF_HEIGHT) -- ซ่อนอยู่ขวานอกจอ
        notif.BackgroundColor3 = bgColor
        notif.BackgroundTransparency = 0.2
        notif.BorderSizePixel = 0
        notif.Parent = notificationFrame
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = notif
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = mainColor
        stroke.Thickness = 1
        stroke.Parent = notif
        
        -- แถบสีด้านซ้าย
        local sideBar = Instance.new("Frame")
        sideBar.Size = UDim2.new(0, 4, 1, 0)
        sideBar.Position = UDim2.new(0, 0, 0, 0)
        sideBar.BackgroundColor3 = mainColor
        sideBar.BorderSizePixel = 0
        sideBar.Parent = notif
        local sideCorner = Instance.new("UICorner")
        sideCorner.CornerRadius = UDim.new(0, 6)
        sideCorner.Parent = sideBar
        
        local titleLbl = Instance.new("TextLabel")
        titleLbl.Size = UDim2.new(1, -20, 0, 20)
        titleLbl.Position = UDim2.new(0, 15, 0, 5)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Text = tostring(title)
        titleLbl.TextColor3 = mainColor
        titleLbl.Font = Enum.Font.GothamBold
        titleLbl.TextSize = 14
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.Parent = notif
        
        local textLbl = Instance.new("TextLabel")
        textLbl.Size = UDim2.new(1, -20, 1, -30)
        textLbl.Position = UDim2.new(0, 15, 0, 25)
        textLbl.BackgroundTransparency = 1
        textLbl.Text = tostring(text)
        textLbl.TextColor3 = textColor
        textLbl.TextTransparency = 0.2
        textLbl.Font = Enum.Font.Gotham
        textLbl.TextSize = 12
        textLbl.TextXAlignment = Enum.TextXAlignment.Left
        textLbl.TextYAlignment = Enum.TextXAlignment.Top
        textLbl.TextWrapped = true
        textLbl.Parent = notif
        
        -- เพิ่มเข้า Array
        table.insert(activeNotifications, notif)
        
        -- จัดเรียงตำแหน่งใหม่ (Slide In)
        Rearrange()
        
        -- เสียงแจ้งเตือน
        pcall(function()
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://4590662766" -- เสียง UI Click นุ่มๆ
            sound.Volume = 0.5
            sound.Parent = CoreGui
            sound:Play()
            game.Debris:AddItem(sound, 2)
        end)
        
        -- ลบอัตโนมัติเมื่อหมดเวลา
        task.spawn(function()
            task.wait(duration)
            -- ค่อยๆ จางหายไป
            local fadeInfo = TweenInfo.new(0.5)
            TweenService:Create(notif, fadeInfo, {BackgroundTransparency = 1}):Play()
            TweenService:Create(stroke, fadeInfo, {Transparency = 1}):Play()
            TweenService:Create(sideBar, fadeInfo, {BackgroundTransparency = 1}):Play()
            TweenService:Create(titleLbl, fadeInfo, {TextTransparency = 1}):Play()
            TweenService:Create(textLbl, fadeInfo, {TextTransparency = 1}):Play()
            
            task.wait(0.5)
            
            -- ลบออกจาก array
            for i, v in ipairs(activeNotifications) do
                if v == notif then
                    table.remove(activeNotifications, i)
                    break
                end
            end
            
            notif:Destroy()
            Rearrange() -- เลื่อนอันที่เหลือลงมา
        end)
    end

    -- Hook เข้าสู่ RYS.Notify 
    function Notifications.Init()
        RYS.Notify = function(title, text, duration)
            -- เช็คจากชื่อ Title ว่าเป็นแนวไหนเพื่อใส่สี
            local cType = "Primary"
            if string.match(string.lower(tostring(title)), "error") or string.match(string.lower(tostring(text)), "fail") then
                cType = "Error"
            elseif string.match(string.lower(tostring(text)), "สำเร็จ") or string.match(string.lower(tostring(text)), "loaded") then
                cType = "Success"
            end
            
            Notifications.Notify(title, text, duration, cType)
        end
    end

    RYS.RegisterModule("Notifications", Notifications)
    return Notifications
end
