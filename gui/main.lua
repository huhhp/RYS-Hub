--[[
    RYS Hub — Main GUI v5.0
    
    🎨 Premium Neon Glassmorphism Dashboard
    ⚡ Advanced Tab Switcher (Combat, Movement, Defense, Exploits, Settings)
--]]

return function(RYS, Components)
    local CoreGui = RYS.Services.CoreGui
    local TweenService = RYS.Services.TweenService
    local UIS = RYS.Services.UserInputService
    local sizes = Components.Sizes
    local M = RYS.Modules

    local function CreateGUI()
        -- ล้างตัวเก่าที่ค้างอยู่ป้องกัน UI ทับซ้อน
        pcall(function() CoreGui:FindFirstChild("RYS_Hub"):Destroy() end)

        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "RYS_Hub"
        ScreenGui.ResetOnSpawn = false
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

        -- โดนห่อหุ้มใน API ความปลอดภัยของ RYS Core
        RYS.Security.ProtectGui(ScreenGui)

        -- ═══════════════════════════════════════
        -- MAIN DIALOG WINDOW
        -- ═══════════════════════════════════════
        local MainFrame = Instance.new("Frame")
        MainFrame.Name = "MainFrame"
        MainFrame.Size = UDim2.new(0, sizes.guiWidth, 0, sizes.guiHeight)
        MainFrame.Position = UDim2.new(0.5, -sizes.guiWidth/2, 0.5, -sizes.guiHeight/2)
        MainFrame.BackgroundColor3 = Color3.fromRGB(15, 12, 28)
        MainFrame.BackgroundTransparency = 0.15 -- Glassmorphism base
        MainFrame.BorderSizePixel = 0
        MainFrame.Active = true
        MainFrame.Draggable = true
        MainFrame.Parent = ScreenGui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 14)
        corner.Parent = MainFrame

        -- Neon Glow Outline
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(138, 43, 226) -- Electric Violet
        stroke.Thickness = 1.5
        stroke.Parent = MainFrame

        -- อนิเมชันขอบเรืองแสงสลับสีแบบ Gradient
        local strokeTween = TweenService:Create(stroke,
            TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
            { Color = Color3.fromRGB(0, 255, 255) } -- Cyan Glow
        )
        strokeTween:Play()

        -- ═══════════════════════════════════════
        -- TITLE BAR
        -- ═══════════════════════════════════════
        local TitleBar = Instance.new("Frame")
        TitleBar.Size = UDim2.new(1, 0, 0, 50)
        TitleBar.BackgroundColor3 = Color3.fromRGB(22, 16, 40)
        TitleBar.BackgroundTransparency = 0.4
        TitleBar.BorderSizePixel = 0
        TitleBar.Parent = MainFrame

        local titleCorner = Instance.new("UICorner")
        titleCorner.CornerRadius = UDim.new(0, 14)
        titleCorner.Parent = TitleBar

        -- บล็อกขอบมนด้านล่างของ TitleBar เพื่อไม่ให้ทับกับ Content Area
        local titleCornerBlock = Instance.new("Frame")
        titleCornerBlock.Size = UDim2.new(1, 0, 0, 15)
        titleCornerBlock.Position = UDim2.new(0, 0, 1, -15)
        titleCornerBlock.BackgroundColor3 = Color3.fromRGB(22, 16, 40)
        titleCornerBlock.BackgroundTransparency = 0.4
        titleCornerBlock.BorderSizePixel = 0
        titleCornerBlock.Parent = TitleBar

        local TitleText = Instance.new("TextLabel")
        TitleText.Size = UDim2.new(1, -100, 1, 0)
        TitleText.Position = UDim2.new(0, 16, 0, 0)
        TitleText.BackgroundTransparency = 1
        TitleText.Text = "⚡ RYS ULTIMATE HUB v5.0" .. (RYS.IsMobile and " 📱" or "")
        TitleText.TextColor3 = Color3.fromRGB(220, 200, 255)
        TitleText.Font = Enum.Font.GothamBold
        TitleText.TextSize = sizes.titleSize
        TitleText.TextXAlignment = Enum.TextXAlignment.Left
        TitleText.Parent = TitleBar

        -- ปุ่ม Close
        local CloseBtn = Instance.new("TextButton")
        CloseBtn.Size = UDim2.new(0, 26, 0, 26)
        CloseBtn.Position = UDim2.new(1, -38, 0, 12)
        CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 90)
        CloseBtn.Text = "✕"
        CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        CloseBtn.Font = Enum.Font.GothamBold
        CloseBtn.TextSize = 11
        CloseBtn.Parent = TitleBar

        local closeCorner = Instance.new("UICorner")
        closeCorner.CornerRadius = UDim.new(0, 6)
        closeCorner.Parent = CloseBtn

        -- ปุ่ม Minimize
        local MinBtn = Instance.new("TextButton")
        MinBtn.Size = UDim2.new(0, 26, 0, 26)
        MinBtn.Position = UDim2.new(1, -70, 0, 12)
        MinBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 40)
        MinBtn.Text = "—"
        MinBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
        MinBtn.Font = Enum.Font.GothamBold
        MinBtn.TextSize = 11
        MinBtn.Parent = TitleBar

        local minCorner = Instance.new("UICorner")
        minCorner.CornerRadius = UDim.new(0, 6)
        minCorner.Parent = MinBtn

        -- ═══════════════════════════════════════
        -- SIDEBAR (NAVIGATION PANEL)
        -- ═══════════════════════════════════════
        local Sidebar = Instance.new("Frame")
        Sidebar.Size = UDim2.new(0, sizes.sidebarWidth, 1, -50)
        Sidebar.Position = UDim2.new(0, 0, 0, 50)
        Sidebar.BackgroundColor3 = Color3.fromRGB(11, 8, 22)
        Sidebar.BackgroundTransparency = 0.5
        Sidebar.BorderSizePixel = 0
        Sidebar.Parent = MainFrame

        local sidebarCorner = Instance.new("UICorner")
        sidebarCorner.CornerRadius = UDim.new(0, 14)
        sidebarCorner.Parent = Sidebar

        -- บล็อกขอบมนด้านบนขวาเพื่อความกลมกลืน
        local sidebarBlock = Instance.new("Frame")
        sidebarBlock.Size = UDim2.new(0, 15, 1, 0)
        sidebarBlock.Position = UDim2.new(1, -15, 0, 0)
        sidebarBlock.BackgroundColor3 = Color3.fromRGB(11, 8, 22)
        sidebarBlock.BackgroundTransparency = 0.5
        sidebarBlock.BorderSizePixel = 0
        sidebarBlock.Parent = Sidebar

        local sidebarList = Instance.new("UIListLayout")
        sidebarList.SortOrder = Enum.SortOrder.LayoutOrder
        sidebarList.Padding = UDim.new(0, 6)
        sidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Center
        sidebarList.Parent = Sidebar

        local sidebarPadding = Instance.new("UIPadding")
        sidebarPadding.PaddingTop = UDim.new(0, 10)
        sidebarPadding.Parent = Sidebar

        -- ═══════════════════════════════════════
        -- CONTENT HOUSING (TABS FRAMES)
        -- ═══════════════════════════════════════
        local ContentHolder = Instance.new("Frame")
        ContentHolder.Size = UDim2.new(1, -sizes.sidebarWidth - 10, 1, -60)
        ContentHolder.Position = UDim2.new(0, sizes.sidebarWidth + 5, 0, 55)
        ContentHolder.BackgroundTransparency = 1
        ContentHolder.Parent = MainFrame

        -- สารบัญแท็บทั้งหมดและฟังก์ชันที่เกี่ยวข้อง
        local tabFrames = {}
        local tabSetButtons = {}
        local activeTabName = ""

        local function CreateTabFrame(tabName)
            local frame = Instance.new("ScrollingFrame")
            frame.Name = tabName .. "_Frame"
            frame.Size = UDim2.new(1, 0, 1, 0)
            frame.BackgroundTransparency = 1
            frame.ScrollBarThickness = 4
            frame.ScrollBarImageColor3 = Color3.fromRGB(138, 43, 226)
            frame.Visible = false
            frame.CanvasSize = UDim2.new(0, 0, 0, 800)
            frame.Parent = ContentHolder

            local listLayout = Instance.new("UIListLayout")
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            listLayout.Padding = UDim.new(0, 8)
            listLayout.Parent = frame

            local padding = Instance.new("UIPadding")
            padding.PaddingLeft = UDim.new(0, 5)
            padding.PaddingRight = UDim.new(0, 10)
            padding.PaddingTop = UDim.new(0, 5)
            padding.Parent = frame

            listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                frame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20)
            end)

            tabFrames[tabName] = frame
            return frame
        end

        local function SwitchTab(tabName)
            if activeTabName == tabName then return end
            
            -- ซ่อนตัวปัจจุบัน
            for name, frame in pairs(tabFrames) do
                frame.Visible = (name == tabName)
                if name == tabName then
                    -- อนิเมชัน Fade-in เบาๆ ของโมดูลภายในแท็บ
                    frame.GroupTransparency = 1
                    TweenService:Create(frame, TweenInfo.new(0.2), { GroupTransparency = 0 }):Play()
                end
            end

            -- อัปเดตการเลือกสีของปุ่ม Sidebar
            for name, setBtn in pairs(tabSetButtons) do
                setBtn(name == tabName)
            end
            
            activeTabName = tabName
        end

        local function RegisterTab(tabName, emoji)
            local frame = CreateTabFrame(tabName)
            
            -- สร้างปุ่ม Sidebar
            local _, setBtn = Components.CreateTabButton(Sidebar, tabName, emoji, function(activeSetter)
                SwitchTab(tabName)
            end, false)
            
            tabSetButtons[tabName] = setBtn
            return frame
        end

        -- ═══════════════════════════════════════
        -- TAB 1: COMBAT & AIMBOT
        -- ═══════════════════════════════════════
        local combatFrame = RegisterTab("Combat", "🎯")
        do
            Components.CreateSectionLabel(combatFrame, "━━━ 🎯 Target Settings ━━━")
            Components.CreateToggleButton(combatFrame, "Aimbot Lock", "🎯", "ล็อคเป้าหมายศัตรูอัตโนมัติเมื่อเล็งหรือโจมตี", RYS.Enabled.Aimbot, function(s) M.Aimbot.Toggle(s) end)
            Components.CreateSlider(combatFrame, "Aimbot FOV", "🔭", 30, 600, RYS.Settings.AimbotFOV, function(val) RYS.Settings.AimbotFOV = val end)
            Components.CreateSlider(combatFrame, "Aimbot Smoothing", "🔄", 1, 100, math.floor(RYS.Settings.AimbotSmoothing * 100), function(val) RYS.Settings.AimbotSmoothing = val / 100 end)
            
            Components.CreateSectionLabel(combatFrame, "━━━ 👁️ ESP & Visuals ━━━")
            Components.CreateToggleButton(combatFrame, "Player ESP", "👁️", "แสดงตำแหน่งโครงร่างและข้อมูลผู้เล่นทะลุกำแพง", RYS.Enabled.ESP, function(s) M.ESP.Toggle(s) end)
            
            Components.CreateSectionLabel(combatFrame, "━━━ ⚔️ Combat Assistance ━━━")
            Components.CreateToggleButton(combatFrame, "Kill Aura", "⚔️", "โจมตีผู้เล่นอื่นในระยะโดยอัตโนมัติ", RYS.Enabled.KillAura, function(s) M.KillAura.Toggle(s) end)
            Components.CreateSlider(combatFrame, "Aura Range", "📏", 5, 50, RYS.Settings.KillAuraRange, function(val) RYS.Settings.KillAuraRange = val end)
            Components.CreateToggleButton(combatFrame, "Hitbox Expander", "📦", "ขยายขนาดหัวและตัวคู่ต่อสู้ให้โจมตีโดนง่ายขึ้น", RYS.Enabled.HitboxExpander, function(s) M.Hitbox.Toggle(s) end)
            Components.CreateSlider(combatFrame, "Hitbox Size multiplier", "📏", 2, 30, RYS.Settings.HitboxSize, function(val) RYS.Settings.HitboxSize = val end)
        end

        -- ═══════════════════════════════════════
        -- TAB 2: MOVEMENT & SPEED
        -- ═══════════════════════════════════════
        local moveFrame = RegisterTab("Movement", "🏃")
        do
            Components.CreateSectionLabel(moveFrame, "━━━ ✈️ Flight controls ━━━")
            Components.CreateToggleButton(moveFrame, "Fly Hack", "✈️", "บินในอากาศได้อย่างอิสระ (ไม่จำกัดความสูง)", RYS.Enabled.Fly, function(s) M.Fly.Toggle(s) end)
            Components.CreateSlider(moveFrame, "Flight Speed", "⚡", 20, 300, RYS.Settings.FlySpeed, function(val) RYS.Settings.FlySpeed = val end)
            
            Components.CreateSectionLabel(moveFrame, "━━━ ⚡ Velocity & Speed ━━━")
            Components.CreateToggleButton(moveFrame, "WalkSpeed Mod", "💨", "เปลี่ยนความเร็วการวิ่งพื้นฐานของตัวละคร", RYS.Enabled.Speed, function(s) M.Speed.Toggle(s) end)
            Components.CreateSlider(moveFrame, "WalkSpeed value", "🏃", 16, 250, RYS.Settings.WalkSpeed, function(val) RYS.Settings.WalkSpeed = val end)
            Components.CreateSlider(moveFrame, "JumpPower value", "🦘", 50, 350, RYS.Settings.JumpPower, function(val) RYS.Settings.JumpPower = val end)
            
            Components.CreateSectionLabel(moveFrame, "━━━ 👻 Ghost & Physics ━━━")
            Components.CreateToggleButton(moveFrame, "Noclip", "👻", "เดินทะลุกำแพง", RYS.Enabled.Noclip, function(s) if M.Noclip then M.Noclip.Toggle(s) end end)
            Components.CreateToggleButton(moveFrame, "Infinite Jump", "🐰", "กระโดดได้ไม่จำกัดกลางอากาศ", RYS.Enabled.InfJump, function(s) if M.InfJump then M.InfJump.Toggle(s) end end)
        
            -- Waypoints Section
            local movementWaypointsFrame = Components.CreateSection(moveFrame)
            Components.CreateSectionLabel(movementWaypointsFrame, "━━━ 📍 Waypoints ━━━")
            
            -- Create a wrapper frame for the textbox to have a proper size
            local wpWrapper = Instance.new("Frame")
            wpWrapper.Size = UDim2.new(1, -20, 0, 30)
            wpWrapper.BackgroundTransparency = 1
            wpWrapper.Parent = movementWaypointsFrame
            
            local wpNameInput = Instance.new("TextBox")
            wpNameInput.Size = UDim2.new(1, 0, 1, 0)
            wpNameInput.PlaceholderText = "Enter Waypoint Name"
            wpNameInput.Text = ""
            wpNameInput.BackgroundColor3 = Color3.fromRGB(30, 25, 45)
            wpNameInput.TextColor3 = Color3.fromRGB(220, 200, 255)
            wpNameInput.Parent = wpWrapper
            
            Components.CreateActionButton(movementWaypointsFrame, "Save Current Position", "📍", function()
                if M.Waypoints and wpNameInput.Text ~= "" then
                    M.Waypoints.SavePosition(wpNameInput.Text)
                    wpNameInput.Text = ""
                end
            end)
            
            Components.CreateActionButton(movementWaypointsFrame, "Teleport to Location", "✈️", function()
                if M.Waypoints and wpNameInput.Text ~= "" then
                    M.Waypoints.TeleportTo(wpNameInput.Text)
                end
            end)

            Components.CreateToggleButton(moveFrame, "Freecam Camera", "📹", "ถอดกล้องออกจากตัวเพื่อบินสำรวจแผนที่อิสระ", RYS.Enabled.Freecam, function(s) M.Freecam.Toggle(s) end)
        end

        -- ═══════════════════════════════════════
        -- TAB 3: DEFENSE & SECURITY
        -- ═══════════════════════════════════════
        local defenseFrame = RegisterTab("Defense", "🛡️")
        do
            Components.CreateSectionLabel(defenseFrame, "━━━ 🛡️ Health & Camouflage ━━━")
            Components.CreateToggleButton(defenseFrame, "Semi GodMode", "❤️", "ล็อกเลือดและพยายามป้องกันการตายจากการโจมตีทั่วไป", RYS.Enabled.GodMode, function(s) M.GodMode.Toggle(s) end)
            Components.CreateToggleButton(defenseFrame, "Invisible Mode", "𫫇", "หายตัวจากการมองเห็นของผู้เล่นอื่น (ต้องการจุดเกิดใหม่)", RYS.Enabled.Invisibility, function(s) M.Invisible.Toggle(s) end)
            
            Components.CreateSectionLabel(defenseFrame, "━━━ ⚙️ Connection Protection ━━━")
            Components.CreateToggleButton(defenseFrame, "Anti-Kick Shield", "🚫", "สกัดกั้นการส่ง Remote Kick ของฝั่งเซิร์ฟเวอร์", RYS.Enabled.AntiKick, function(s) M.AntiKick.Toggle(s) end)
            Components.CreateToggleButton(defenseFrame, "Anti-AFK Preventer", "💤", "จำลองการคลิกและคีย์บอร์ดเพื่อป้องกันการถูกตัดการเชื่อมต่อ", RYS.Enabled.AntiAFK, function(s) M.AntiAFK.Toggle(s) end)
            Components.CreateToggleButton(defenseFrame, "7-Layer AC Bypass", "🛡️", "เปิดระบบสแกนและหลบหลีกการสุ่มตรวจจับของ Anti-Cheat", RYS.Enabled.AntiCheat, function(s) M.AntiCheat.Toggle(s) end)
        end

        -- ═══════════════════════════════════════
        -- TAB 4: EXPLOITS & UTILITIES
        -- ═══════════════════════════════════════
        local exploitFrame = RegisterTab("Exploits", "💰")
        do
            Components.CreateSectionLabel(exploitFrame, "━━━ 📡 Network & Packets ━━━")
            Components.CreateToggleButton(exploitFrame, "Remote Spy Monitor", "📡", "ดักจับและแสดง Log การส่งข้อความ Remotes ทั้งหมดในแชทบ็อกซ์", RYS.Enabled.RemoteSpy, function(s) M.RemoteSpy.Toggle(s) end)
            Components.CreateToggleButton(exploitFrame, "Smart Auto-Farm", "🌾", "เริ่มการสแกนเป้าหมายฟาร์มและเดินทางไปฟาร์มของอัตโนมัติ", RYS.Enabled.AutoFarm, function(s) M.AutoFarm.Toggle(s) end)
            
            Components.CreateSectionLabel(exploitFrame, "━━━ ⚡ Fast Commands ━━━")
            Components.CreateActionButton(exploitFrame, "Bring All Players to Me", "🧲", function() M.BringAll.Execute() end)
            Components.CreateActionButton(exploitFrame, "Server Hop (Teleport Join)", "🔄", function() M.ServerHop.Hop() end)
            Components.CreateActionButton(exploitFrame, "Scan Workspace ValueMod", "🔍", function() M.ValueMod.ScanValues() end)
            
            Components.CreateSectionLabel(exploitFrame, "━━━ 🗣️ Chat Options ━━━")
            Components.CreateActionButton(exploitFrame, "Chat Spammer (RYS Active)", "💬", function() M.ChatSpam.Execute() end)
            
            Components.CreateSectionLabel(exploitFrame, "━━━ 🔓 ULTIMATE BYPASS ENGINE ━━━")
            Components.CreateToggleButton(exploitFrame, "GamePass Bypass", "🔓", "Hook ownership checks ให้เกมเชื่อว่าคุณเป็นเจ้าของ GamePass ทั้งหมด (Client-Side)", RYS.Enabled.GamePassBypass, function(s) M.GamePass.Toggle(s) end)
            Components.CreateToggleButton(exploitFrame, "Auto Unlock All Items", "🔑", "สแกนและปลดล็อคไอเท็ม + Clone Tools ทั้งหมดลง Backpack อัตโนมัติ", RYS.Enabled.UnlockAll, function(s) M.UnlockAll.Toggle(s) end)
            Components.CreateActionButton(exploitFrame, "Unlock All (One-Shot)", "🎁", function() M.UnlockAll.Execute() end)
            
            Components.CreateSectionLabel(exploitFrame, "━━━ 📦 ITEM SPAWN & DUPE ━━━")
            Components.CreateActionButton(exploitFrame, "Scan & Spawn All Tools", "📦", function() M.ItemSpawn.Execute() end)
            Components.CreateActionButton(exploitFrame, "Scan Item Catalog (F9)", "🔍", function() M.ItemSpawn.Scan() end)
            Components.CreateToggleButton(exploitFrame, "Auto-Dupe Engine", "🔁", "ระบบ Dupe อัตโนมัติ — Clone + Remote Replay ทุก 30 วินาที", RYS.Enabled.DupeEngine, function(s) M.Dupe.Toggle(s) end)
            Components.CreateActionButton(exploitFrame, "MEGA DUPE (All Methods)", "💥", function() M.Dupe.Execute() end)
            Components.CreateActionButton(exploitFrame, "Overflow Dupe x50", "🌊", function() M.Dupe.OverflowDupe(50) end)
        end

        -- ═══════════════════════════════════════
        -- TAB 5: SETTINGS & METRICS
        -- ═══════════════════════════════════════
        local settingsFrame = RegisterTab("Settings", "⚙️")
        do
            Components.CreateSectionLabel(settingsFrame, "━━━ ⚙️ System Profiles ━━━")
            
            -- โชว์ข้อมูลระบบตรวจจับปัจจุบัน
            local execLabel = Instance.new("TextLabel")
            execLabel.Size = UDim2.new(1, -10, 0, 24)
            execLabel.BackgroundTransparency = 1
            execLabel.Text = "🛡️ Active Executor: " .. tostring(RYS.Executor)
            execLabel.TextColor3 = Color3.fromRGB(0, 255, 200)
            execLabel.Font = Enum.Font.GothamMedium
            execLabel.TextSize = sizes.fontSize
            execLabel.TextXAlignment = Enum.TextXAlignment.Left
            execLabel.Parent = settingsFrame

            local pingLabel = Instance.new("TextLabel")
            pingLabel.Size = UDim2.new(1, -10, 0, 24)
            pingLabel.BackgroundTransparency = 1
            pingLabel.Text = "📡 Server ping: Calculating..."
            pingLabel.TextColor3 = Color3.fromRGB(180, 160, 220)
            pingLabel.Font = Enum.Font.GothamMedium
            pingLabel.TextSize = sizes.fontSize
            pingLabel.TextXAlignment = Enum.TextXAlignment.Left
            pingLabel.Parent = settingsFrame

            -- คำนวณ Ping และอัปเดตแบบเรียลไทม์
            task.spawn(function()
                while task.wait(2) and pingLabel.Parent do
                    local pingVal = tonumber(string.format("%.1f", Players.LocalPlayer:GetNetworkPing() * 1000))
                    pingLabel.Text = "📡 Server ping: " .. tostring(pingVal) .. " ms"
                end
            end)

            Components.CreateSectionLabel(settingsFrame, "━━━ 💾 Core Config System ━━━")
            Components.CreateToggleButton(settingsFrame, "Auto-Save Settings", "💾", "บันทึกค่าและสถานะทุกอย่างอัตโนมัติ (ทุก 3 นาที)", RYS.Settings.AutoSave, function(s) RYS.Settings.AutoSave = s end)
            Components.CreateActionButton(settingsFrame, "Save Config Now", "📥", function() if M.Config then M.Config.Save() end end)
            Components.CreateActionButton(settingsFrame, "Load Config", "📤", function() if M.Config then M.Config.Load() end end)
            
            Components.CreateSectionLabel(settingsFrame, "━━━ 🎭 Theme & Monitor ━━━")
            Components.CreateToggleButton(settingsFrame, "Overlay Monitor", "📊", "แสดงสถานะ FPS/Ping บนหน้าจอ", RYS.Enabled.MonitorWidget, function(s) if M.MonitorWidget then M.MonitorWidget.Toggle(s) end end)
            
            -- Theme Cycler
            local themeNames = {"Electric Violet (Default)", "Crimson Blood", "Neon Matrix", "Gold Luxury"}
            local currentThemeIdx = 1
            for i, v in ipairs(themeNames) do if v == RYS.Settings.ActiveTheme then currentThemeIdx = i break end end
            
            local themeBtn = Components.CreateActionButton(settingsFrame, "Current Theme: " .. themeNames[currentThemeIdx], "🎨", function()
                currentThemeIdx = currentThemeIdx + 1
                if currentThemeIdx > #themeNames then currentThemeIdx = 1 end
                if M.Themes then M.Themes.SetTheme(themeNames[currentThemeIdx]) end
                -- Update button text doesn't exist out of the box in ActionButton, so we'll just let them see the change
                RYS.Notify("Theme", "เปลี่ยนธีมเป็น " .. themeNames[currentThemeIdx])
            end)
            
            Components.CreateSectionLabel(settingsFrame, "━━━ 🛡️ Quick Profiles ━━━")
            Components.CreateActionButton(settingsFrame, "Save as PVP Profile", "⚔️", function() if M.Profiles then M.Profiles.SaveProfile("PVP_Profile") end end)
            Components.CreateActionButton(settingsFrame, "Load PVP Profile", "⚔️", function() if M.Profiles then M.Profiles.LoadProfile("PVP_Profile") end end)
            Components.CreateActionButton(settingsFrame, "Save as Farm Profile", "🌾", function() if M.Profiles then M.Profiles.SaveProfile("Farm_Profile") end end)
            Components.CreateActionButton(settingsFrame, "Load Farm Profile", "🌾", function() if M.Profiles then M.Profiles.LoadProfile("Farm_Profile") end end)

            Components.CreateSectionLabel(settingsFrame, "━━━ 🗑️ Memory & cache ━━━")
            Components.CreateActionButton(settingsFrame, "Collect Garbage (Memory Cleanup)", "🧹", function()
                local before = gcinfo()
                RYS.Cleanup()
                local after = gcinfo()
                RYS.Notify("Memory", "ล้างเสร็จสิ้น! คืนค่าแรม: " .. tostring(before - after) .. " KB")
            end)
            
            Components.CreateActionButton(settingsFrame, "Clear Local Cache (Re-download next boot)", "🗑️", function()
                if delfolder and isfolder("RYS_Cache") then
                    pcall(delfolder, "RYS_Cache")
                    RYS.Notify("Cache", "ลบโฟลเดอร์แคชสำเร็จ! กรุณารันโหลดเดอร์ใหม่เพื่อดาวน์โหลดตัวล่าสุด")
                else
                    RYS.Notify("Cache", "Executor ของท่านไม่รองรับการเขียน/ลบไฟล์ในระดับโฟลเดอร์")
                end
            end)

            Components.CreateSectionLabel(settingsFrame, "━━━ ⚡ Hotkey Options ━━━")
            local keyLabel = Instance.new("TextLabel")
            keyLabel.Size = UDim2.new(1, -10, 0, 30)
            keyLabel.BackgroundTransparency = 1
            keyLabel.Text = "🎮 กด RightShift เพื่อ ซ่อน / แสดง เมนูควบคุม"
            keyLabel.TextColor3 = Color3.fromRGB(150, 140, 170)
            keyLabel.Font = Enum.Font.GothamMedium
            keyLabel.TextSize = sizes.fontSize - 1
            keyLabel.TextXAlignment = Enum.TextXAlignment.Left
            keyLabel.Parent = settingsFrame
        end

        -- Load Config on Startup
        if M.Config then
            pcall(function() M.Config.Load() end)
        end

        -- บูตแท็บแรกเป็น default
        SwitchTab("Combat")

        -- ═══════════════════════════════════════
        -- CLOSE & MINIMIZE LOGIC
        -- ═══════════════════════════════════════
        CloseBtn.MouseButton1Click:Connect(function()
            MainFrame.Visible = false
            RYS.Notify("RYS Hub", "✕ ซ่อนแผงควบคุมแล้ว กดปุ่ม ⚡ หรือกด RightShift เพื่อเปิดใหม่")
        end)

        local minimized = false
        MinBtn.MouseButton1Click:Connect(function()
            minimized = not minimized
            Sidebar.Visible = not minimized
            ContentHolder.Visible = not minimized
            
            if minimized then
                TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, sizes.guiWidth, 0, 50)
                }):Play()
                MinBtn.Text = "+"
            else
                TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, sizes.guiWidth, 0, sizes.guiHeight)
                }):Play()
                MinBtn.Text = "—"
            end
        end)

        -- Scale-In Open Animation
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, sizes.guiWidth, 0, sizes.guiHeight),
            Position = UDim2.new(0.5, -sizes.guiWidth/2, 0.5, -sizes.guiHeight/2)
        }):Play()

        RYS.GUI = ScreenGui
        return ScreenGui
    end

    return CreateGUI
end
