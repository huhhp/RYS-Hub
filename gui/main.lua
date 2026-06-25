--[[
    RYS Hub — Main GUI
    สร้าง Main Frame + ปุ่มทั้งหมด
    ✅ ใช้ Components แทนการสร้างซ้ำ
--]]

return function(RYS, Components)
    local CoreGui = RYS.Services.CoreGui
    local TweenService = RYS.Services.TweenService
    local UIS = RYS.Services.UserInputService
    local sizes = Components.Sizes

    local function CreateGUI()
        -- Destroy old
        pcall(function() CoreGui:FindFirstChild("RYS_Hub"):Destroy() end)

        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "RYS_Hub"
        ScreenGui.ResetOnSpawn = false
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        ScreenGui.Parent = CoreGui

        -- Main Frame
        local MainFrame = Instance.new("Frame")
        MainFrame.Name = "MainFrame"
        MainFrame.Size = UDim2.new(0, sizes.guiWidth, 0, sizes.guiHeight)
        MainFrame.Position = UDim2.new(0.5, -sizes.guiWidth/2, 0.5, -sizes.guiHeight/2)
        MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
        MainFrame.BorderSizePixel = 0
        MainFrame.Parent = ScreenGui
        MainFrame.Active = true
        MainFrame.Draggable = true

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 12)
        corner.Parent = MainFrame

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(100, 50, 255)
        stroke.Thickness = 2
        stroke.Parent = MainFrame

        -- ✅ Gradient border animation
        local gradientTween = TweenService:Create(stroke,
            TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
            { Color = Color3.fromRGB(0, 200, 255) }
        )
        gradientTween:Play()

        -- Title Bar
        local TitleBar = Instance.new("Frame")
        TitleBar.Size = UDim2.new(1, 0, 0, 50)
        TitleBar.BackgroundColor3 = Color3.fromRGB(20, 10, 40)
        TitleBar.BorderSizePixel = 0
        TitleBar.Parent = MainFrame

        local titleCorner = Instance.new("UICorner")
        titleCorner.CornerRadius = UDim.new(0, 12)
        titleCorner.Parent = TitleBar

        local TitleText = Instance.new("TextLabel")
        TitleText.Size = UDim2.new(1, -60, 1, 0)
        TitleText.Position = UDim2.new(0, 15, 0, 0)
        TitleText.BackgroundTransparency = 1
        TitleText.Text = "⚡ RYS HUB v4.0" .. (RYS.IsMobile and " 📱" or "")
        TitleText.TextColor3 = Color3.fromRGB(180, 130, 255)
        TitleText.Font = Enum.Font.GothamBold
        TitleText.TextSize = sizes.titleSize
        TitleText.TextXAlignment = Enum.TextXAlignment.Left
        TitleText.Parent = TitleBar

        -- Close Button
        local CloseBtn = Instance.new("TextButton")
        CloseBtn.Size = UDim2.new(0, 30, 0, 30)
        CloseBtn.Position = UDim2.new(1, -40, 0, 10)
        CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        CloseBtn.Text = "✕"
        CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        CloseBtn.Font = Enum.Font.GothamBold
        CloseBtn.TextSize = 14
        CloseBtn.Parent = TitleBar

        local closeCorner = Instance.new("UICorner")
        closeCorner.CornerRadius = UDim.new(0, 8)
        closeCorner.Parent = CloseBtn

        -- Minimize
        local MinBtn = Instance.new("TextButton")
        MinBtn.Size = UDim2.new(0, 30, 0, 30)
        MinBtn.Position = UDim2.new(1, -75, 0, 10)
        MinBtn.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
        MinBtn.Text = "—"
        MinBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
        MinBtn.Font = Enum.Font.GothamBold
        MinBtn.TextSize = 14
        MinBtn.Parent = TitleBar

        local minCorner = Instance.new("UICorner")
        minCorner.CornerRadius = UDim.new(0, 8)
        minCorner.Parent = MinBtn

        -- Scroll Frame
        local ScrollFrame = Instance.new("ScrollingFrame")
        ScrollFrame.Size = UDim2.new(1, -20, 1, -60)
        ScrollFrame.Position = UDim2.new(0, 10, 0, 55)
        ScrollFrame.BackgroundTransparency = 1
        ScrollFrame.ScrollBarThickness = 4
        ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 50, 255)
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 1200)
        ScrollFrame.Parent = MainFrame

        local listLayout = Instance.new("UIListLayout")
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Padding = UDim.new(0, 6)
        listLayout.Parent = ScrollFrame

        -- ═══════════════════════════════════════
        -- CREATE ALL BUTTONS (ใช้ modules จาก RYS.Modules)
        -- ═══════════════════════════════════════
        local M = RYS.Modules
        local CT = Components.CreateToggleButton
        local CA = Components.CreateActionButton
        local CS = Components.CreateSectionLabel

        CS(ScrollFrame, "━━━ 🎯 COMBAT ━━━", 1)
        CT(ScrollFrame, "Aimbot", "🎯", "Auto aim", function(s) M.Aimbot.Toggle(s) end, 2)
        CT(ScrollFrame, "ESP / Wallhack", "👁️", "See through walls", function(s) M.ESP.Toggle(s) end, 3)
        CT(ScrollFrame, "Kill Aura", "⚔️", "Auto attack", function(s) M.KillAura.Toggle(s) end, 4)
        CT(ScrollFrame, "Hitbox Expander", "📦", "Bigger hitboxes", function(s) M.Hitbox.Toggle(s) end, 5)

        CS(ScrollFrame, "━━━ 🏃 MOVEMENT ━━━", 10)
        CT(ScrollFrame, "Fly Hack", "✈️", "Fly around", function(s) M.Fly.Toggle(s) end, 11)
        CT(ScrollFrame, "Speed Hack", "💨", "Move faster", function(s) M.Speed.Toggle(s) end, 12)
        CT(ScrollFrame, "Noclip", "👻", "Walk through walls", function(s) M.Noclip.Toggle(s) end, 13)
        CT(ScrollFrame, "Infinite Jump", "🦘", "Jump unlimited", function(s) M.InfJump.Toggle(s) end, 14)
        CT(ScrollFrame, "Freecam", "📹", "Free camera", function(s) M.Freecam.Toggle(s) end, 15)

        CS(ScrollFrame, "━━━ 🛡️ DEFENSE ━━━", 20)
        CT(ScrollFrame, "God Mode", "❤️", "Infinite HP", function(s) M.GodMode.Toggle(s) end, 21)
        CT(ScrollFrame, "Invisibility", "🫥", "Become invisible", function(s) M.Invisible.Toggle(s) end, 22)
        CT(ScrollFrame, "Anti-Kick", "🚫", "Prevent kicks", function(s) M.AntiKick.Toggle(s) end, 23)
        CT(ScrollFrame, "Anti-AFK", "💤", "Stay online", function(s) M.AntiAFK.Toggle(s) end, 24)
        CT(ScrollFrame, "Anti-Cheat Bypass", "🛡️", "7-Layer AC", function(s) M.AntiCheat.Toggle(s) end, 25)

        CS(ScrollFrame, "━━━ 💰 EXPLOIT ━━━", 30)
        CT(ScrollFrame, "Remote Spy", "📡", "Spy remotes", function(s) M.RemoteSpy.Toggle(s) end, 31)
        CT(ScrollFrame, "Auto Farm", "🌾", "Auto collect", function(s) M.AutoFarm.Toggle(s) end, 32)
        CA(ScrollFrame, "Scan Values", "🔍", function() M.ValueMod.ScanValues() end, 33)

        CS(ScrollFrame, "━━━ ⚡ ACTIONS ━━━", 40)
        CA(ScrollFrame, "Bring All Players", "🧲", function() M.BringAll.Execute() end, 41)
        CA(ScrollFrame, "Server Hop", "🔄", function() M.ServerHop.Hop() end, 42)
        CA(ScrollFrame, "FOV 120°", "🔭", function() M.FOVChanger.Set(120) end, 43)
        CA(ScrollFrame, "Reset FOV", "🔭", function() M.FOVChanger.Set(70) end, 44)

        -- ✅ Auto-resize canvas
        listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20)
        end)

        -- Close/Minimize handlers
        CloseBtn.MouseButton1Click:Connect(function()
            MainFrame.Visible = false
            RYS.Notify("Hub", "❌ ซ่อน Hub แล้ว — กดปุ่ม ⚡ เพื่อเปิดใหม่")
        end)

        local minimized = false
        MinBtn.MouseButton1Click:Connect(function()
            minimized = not minimized
            ScrollFrame.Visible = not minimized
            if minimized then
                TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
                    Size = UDim2.new(0, sizes.guiWidth, 0, 55)
                }):Play()
                MinBtn.Text = "+"
            else
                TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
                    Size = UDim2.new(0, sizes.guiWidth, 0, sizes.guiHeight)
                }):Play()
                MinBtn.Text = "—"
            end
        end)

        -- Open animation
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
            Size = UDim2.new(0, sizes.guiWidth, 0, sizes.guiHeight),
            Position = UDim2.new(0.5, -sizes.guiWidth/2, 0.5, -sizes.guiHeight/2)
        }):Play()

        RYS.GUI = ScreenGui
        return ScreenGui
    end

    return CreateGUI
end
