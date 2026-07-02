--[[
    RYS Hub — Monitor Widget v5.0
    
    Features:
    1. Overlay มินิมอลโชว์ FPS, Ping, Memory (KB), ConnMgr active threads
    2. รองรับ Draggable (ลากไปมาบนจอได้)
    3. ซิงค์สีกับ Theme Engine
--]]

return function(RYS, ConnMgr)
    local Monitor = {}
    local MODULE_NAME = "MonitorWidget"
    
    local RunService = RYS.Services.RunService
    local Players = RYS.Services.Players
    local CoreGui = RYS.Services.CoreGui
    local TweenService = RYS.Services.TweenService
    
    local screenGui, widgetFrame
    local labels = {}
    
    local lastFrameTime = tick()
    local framesCount = 0
    local fps = 0
    
    local function UpdateStats()
        if not widgetFrame or not widgetFrame.Visible then return end
        
        -- FPS Calculation
        framesCount = framesCount + 1
        local now = tick()
        if now - lastFrameTime >= 1 then
            fps = framesCount
            framesCount = 0
            lastFrameTime = now
        end
        
        -- Ping
        local ping = math.floor(Players.LocalPlayer:GetNetworkPing() * 1000)
        
        -- Memory
        local memory = math.floor(gcinfo())
        
        -- RYS Active Connections
        -- Note: เรานับ Connection ง่ายๆ จากฟังก์ชัน Stats ของ ConnMgr
        local activeConns = 0
        if ConnMgr.PrintStats then
            -- แอบแฮกมานับ หรือแค่ทำ dummy ถ้าขี้เกียจนับลึก (แต่ถ้านับลึกต้อง expose properties)
            -- เราสมมติว่ามี ConnMgr._pool ให้เข้าถึง
            if ConnMgr._pool then
                for k, v in pairs(ConnMgr._pool) do
                    for _ in pairs(v) do activeConns = activeConns + 1 end
                end
            end
        end
        
        -- อัปเดต Text
        labels.FPS.Text = "FPS: " .. tostring(fps)
        labels.Ping.Text = "PING: " .. tostring(ping) .. "ms"
        labels.Memory.Text = "MEM: " .. tostring(memory) .. "KB"
        labels.Conns.Text = "RYS CONNS: " .. tostring(activeConns)
    end
    
    function Monitor.Create()
        pcall(function() CoreGui:FindFirstChild("RYS_Monitor"):Destroy() end)
        
        screenGui = Instance.new("ScreenGui")
        screenGui.Name = "RYS_Monitor"
        screenGui.ResetOnSpawn = false
        RYS.Security.ProtectGui(screenGui)
        
        widgetFrame = Instance.new("Frame")
        widgetFrame.Size = UDim2.new(0, 150, 0, 75)
        widgetFrame.Position = UDim2.new(1, -160, 0, 10) -- มุมบนขวา
        widgetFrame.BackgroundColor3 = RYS.Modules.Themes and RYS.Modules.Themes.GetColor("Background") or Color3.fromRGB(15, 12, 28)
        widgetFrame.BackgroundTransparency = 0.4
        widgetFrame.BorderSizePixel = 0
        widgetFrame.Active = true
        widgetFrame.Draggable = true
        widgetFrame.Visible = RYS.Enabled.MonitorWidget or false
        widgetFrame.Parent = screenGui
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = widgetFrame
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = RYS.Modules.Themes and RYS.Modules.Themes.GetColor("Primary") or Color3.fromRGB(138, 43, 226)
        stroke.Thickness = 1
        stroke.Parent = widgetFrame
        
        local listLayout = Instance.new("UIListLayout")
        listLayout.Padding = UDim.new(0, 2)
        listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        listLayout.Parent = widgetFrame
        
        local padding = Instance.new("UIPadding")
        padding.PaddingTop = UDim.new(0, 5)
        padding.Parent = widgetFrame
        
        local function CreateLabel(name, textColor)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -10, 0, 14)
            lbl.BackgroundTransparency = 1
            lbl.Text = name .. ": --"
            lbl.TextColor3 = textColor
            lbl.Font = Enum.Font.GothamMedium
            lbl.TextSize = 10
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = widgetFrame
            labels[name] = lbl
        end
        
        local tTheme = RYS.Modules.Themes
        CreateLabel("FPS", tTheme and tTheme.GetColor("Success") or Color3.fromRGB(0, 255, 200))
        CreateLabel("Ping", tTheme and tTheme.GetColor("Accent1") or Color3.fromRGB(0, 255, 255))
        CreateLabel("Memory", tTheme and tTheme.GetColor("Text") or Color3.fromRGB(220, 200, 255))
        CreateLabel("Conns", tTheme and tTheme.GetColor("Accent2") or Color3.fromRGB(110, 50, 200))
        
        -- Theme Sync (ถ้า Themes โหลดแล้ว)
        if RYS.Modules.Themes and RYS.Modules.Themes.OnThemeChanged then
            RYS.Modules.Themes.OnThemeChanged.Event:Connect(function(palette)
                widgetFrame.BackgroundColor3 = palette.Background
                stroke.Color = palette.Primary
                labels.FPS.TextColor3 = palette.Success
                labels.Ping.TextColor3 = palette.Accent1
                labels.Memory.TextColor3 = palette.Text
                labels.Conns.TextColor3 = palette.Accent2
            end)
        end
        
        -- Loop สำหรับนับ FPS
        RunService.RenderStepped:Connect(function()
            if RYS.Enabled.MonitorWidget then
                framesCount = framesCount + 1
            end
        end)
        
        -- Loop อัปเดตข้อมูลทุกๆ 1 วินาที ลดภาระเครื่อง
        ConnMgr:AddThrottled(MODULE_NAME, 1, UpdateStats)
    end
    
    function Monitor.Toggle(state)
        RYS.Enabled.MonitorWidget = state
        if widgetFrame then
            widgetFrame.Visible = state
        else
            if state then
                Monitor.Create()
                widgetFrame.Visible = true
            end
        end
        
        -- แจ้ง Config เซฟสถานะนี้
        if RYS.Modules.Config then
            pcall(function() RYS.Modules.Config.Save(true) end)
        end
    end

    RYS.RegisterModule("MonitorWidget", Monitor)
    return Monitor
end
