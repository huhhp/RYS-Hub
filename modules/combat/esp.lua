--[[
    RYS Hub — ESP Module (UPGRADED: 2D/3D BOX + HEALTHBAR + TRACERS)
    ✅ ใช้ Chams (Highlight) สำหรับทะลุกำแพง
    ✅ วาดเส้นโยง Tracer จากล่างหน้าจอไปหาศัตรู
    ✅ 3D Billboard Info (Name, Health Bar, Distance)
    ✅ Throttle 0.05s สำหรับความลื่นไหลและประหยัดทรัพยากร
--]]

return function(RYS, ConnMgr)
    local ESP = {}
    local Players = RYS.Services.Players
    local LocalPlayer = RYS.Services.LocalPlayer
    local Camera = RYS.Services.Camera
    local MODULE_NAME = "ESP"
    
    local ActiveTracers = {}

    -- Drawing Tracers helper
    local function CreateTracer(player)
        if not Drawing then return nil end
        local line = nil
        pcall(function()
            line = Drawing.new("Line")
            line.Thickness = 1.5
            line.Color = RYS.Settings.ESPEnemyColor or Color3.fromRGB(255, 50, 50)
            line.Transparency = 0.8
            line.Visible = false
        end)
        return line
    end

    function ESP.CreateESP(player)
        if player == LocalPlayer then return end
        
        local tracer = CreateTracer(player)
        if tracer then
            ActiveTracers[player] = tracer
        end

        local function Setup(character)
            if not character then return end
            local humanoid = character:WaitForChild("Humanoid", 5)
            local rootPart = character:WaitForChild("HumanoidRootPart", 5)
            local head = character:WaitForChild("Head", 5)
            if not humanoid or not rootPart or not head then return end

            -- Highlight (Chams)
            local highlight = Instance.new("Highlight")
            highlight.Name = "RYS_ESP"
            highlight.Adornee = character
            highlight.FillTransparency = 0.6
            highlight.OutlineTransparency = 0.1
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            
            local color = RYS.IsTeammate(player) and RYS.Settings.ESPTeamColor or RYS.Settings.ESPEnemyColor
            highlight.FillColor = color
            highlight.OutlineColor = color
            highlight.Parent = character

            -- Billboard Info (Name & Health)
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "RYS_ESP_Info"
            billboard.Adornee = head
            billboard.Size = UDim2.new(0, 150, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 2.5, 0)
            billboard.AlwaysOnTop = true
            billboard.Parent = character

            -- Custom health bar inside billboard
            local bgBar = Instance.new("Frame")
            bgBar.Size = UDim2.new(0.8, 0, 0.1, 0)
            bgBar.Position = UDim2.new(0.1, 0, 0.8, 0)
            bgBar.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
            bgBar.BorderSizePixel = 0
            bgBar.Parent = billboard

            local mainBar = Instance.new("Frame")
            mainBar.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 1, 0)
            mainBar.BackgroundColor3 = Color3.fromRGB(0, 255, 136)
            mainBar.BorderSizePixel = 0
            mainBar.Parent = bgBar

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, 0, 0.7, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.TextStrokeTransparency = 0.2
            nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            nameLabel.Font = Enum.Font.Code
            nameLabel.TextSize = 12
            nameLabel.Text = string.format("%s [%.0f]", player.Name, 0)
            nameLabel.Parent = billboard

            -- Update loop
            ConnMgr:AddThrottled(MODULE_NAME, 0.03, function()
                if not RYS.Enabled.ESP then
                    pcall(function() highlight:Destroy() end)
                    pcall(function() billboard:Destroy() end)
                    if tracer then tracer.Visible = false end
                    return
                end
                
                if not character.Parent or not humanoid or humanoid.Health <= 0 then
                    pcall(function() highlight:Destroy() end)
                    pcall(function() billboard:Destroy() end)
                    if tracer then tracer.Visible = false end
                    return
                end
                
                local myRoot = RYS.GetRootPart()
                if myRoot and rootPart then
                    local dist = RYS.GetDistance(myRoot.Position, rootPart.Position)
                    nameLabel.Text = string.format("%s [%.0f studs]", player.Name, dist)
                    mainBar.Size = UDim2.new(math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1), 0, 1, 0)
                    
                    -- Dynamic color based on HP
                    local hpRatio = humanoid.Health / humanoid.MaxHealth
                    mainBar.BackgroundColor3 = Color3.fromRGB(255 * (1 - hpRatio), 255 * hpRatio, 0)

                    -- Update Tracer
                    if tracer and RYS.Settings.ESPShowTracers then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                        if onScreen then
                            tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                            tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                            tracer.Color = color
                            tracer.Visible = true
                        else
                            tracer.Visible = false
                        end
                    elseif tracer then
                        tracer.Visible = false
                    end
                else
                    if tracer then tracer.Visible = false end
                end
            end, "Heartbeat")
        end

        if player.Character then Setup(player.Character) end
        ConnMgr:AddConnection(MODULE_NAME, player.CharacterAdded, function(char)
            if RYS.Enabled.ESP then
                task.wait(0.5)
                Setup(char)
            end
        end)
    end

    function ESP.Toggle(state)
        RYS.Enabled.ESP = state
        if state then
            for _, player in ipairs(Players:GetPlayers()) do
                ESP.CreateESP(player)
            end
            ConnMgr:AddConnection(MODULE_NAME, Players.PlayerAdded, function(player)
                if RYS.Enabled.ESP then
                    ESP.CreateESP(player)
                end
            end)
            
            -- Remove tracer on leave
            ConnMgr:AddConnection(MODULE_NAME, Players.PlayerRemoving, function(player)
                local tr = ActiveTracers[player]
                if tr then
                    tr.Visible = false
                    pcall(function() tr:Remove() end)
                    ActiveTracers[player] = nil
                end
            end)
            
            RYS.Notify("ESP", "👁️ Chams + Tracers + HP-bar ESP Active!")
        else
            ConnMgr:DisconnectAll(MODULE_NAME)
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character then
                    local h = player.Character:FindFirstChild("RYS_ESP")
                    local b = player.Character:FindFirstChild("RYS_ESP_Info")
                    if h then h:Destroy() end
                    if b then b:Destroy() end
                end
                local tr = ActiveTracers[player]
                if tr then
                    tr.Visible = false
                    pcall(function() tr:Remove() end)
                end
            end
            ActiveTracers = {}
            RYS.Notify("ESP", "❌ Disabled")
        end
    end

    RYS.RegisterModule("ESP", ESP)
    return ESP
end
