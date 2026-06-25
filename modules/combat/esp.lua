--[[
    RYS Hub — ESP Module (Optimized)
    ✅ Throttle 0.1s แทน RenderStepped ทุกเฟรม
    ✅ Connection per-player cleanup
    ✅ ใช้ ConnMgr จัดการ
--]]

return function(RYS, ConnMgr)
    local ESP = {}
    local Players = RYS.Services.Players
    local LocalPlayer = RYS.Services.LocalPlayer
    local MODULE_NAME = "ESP"
    
    function ESP.CreateESP(player)
        if player == LocalPlayer then return end
        
        local function Setup(character)
            if not character then return end
            local humanoid = character:WaitForChild("Humanoid", 5)
            local rootPart = character:WaitForChild("HumanoidRootPart", 5)
            local head = character:WaitForChild("Head", 5)
            if not humanoid or not rootPart or not head then return end

            -- Highlight
            local highlight = Instance.new("Highlight")
            highlight.Name = "RYS_ESP"
            highlight.Adornee = character
            highlight.FillTransparency = 0.7
            highlight.OutlineTransparency = 0
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            
            if RYS.IsTeammate(player) then
                highlight.FillColor = RYS.Settings.ESPTeamColor
                highlight.OutlineColor = RYS.Settings.ESPTeamColor
            else
                highlight.FillColor = RYS.Settings.ESPEnemyColor
                highlight.OutlineColor = RYS.Settings.ESPEnemyColor
            end
            highlight.Parent = character

            -- Billboard
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "RYS_ESP_Info"
            billboard.Adornee = head
            billboard.Size = UDim2.new(0, 200, 0, 60)
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            billboard.AlwaysOnTop = true
            billboard.Parent = character

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Name = "NameLabel"
            nameLabel.Size = UDim2.new(1, 0, 0.4, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.TextStrokeTransparency = 0
            nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextSize = 13
            nameLabel.Text = player.Name
            nameLabel.Parent = billboard

            local healthLabel = Instance.new("TextLabel")
            healthLabel.Name = "HealthLabel"
            healthLabel.Size = UDim2.new(1, 0, 0.3, 0)
            healthLabel.Position = UDim2.new(0, 0, 0.4, 0)
            healthLabel.BackgroundTransparency = 1
            healthLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
            healthLabel.TextStrokeTransparency = 0
            healthLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            healthLabel.Font = Enum.Font.GothamBold
            healthLabel.TextSize = 11
            healthLabel.Parent = billboard

            local distLabel = Instance.new("TextLabel")
            distLabel.Name = "DistLabel"
            distLabel.Size = UDim2.new(1, 0, 0.3, 0)
            distLabel.Position = UDim2.new(0, 0, 0.7, 0)
            distLabel.BackgroundTransparency = 1
            distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            distLabel.TextStrokeTransparency = 0
            distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            distLabel.Font = Enum.Font.Gotham
            distLabel.TextSize = 10
            distLabel.Parent = billboard

            -- ✅ OPTIMIZED: Throttle 0.1s แทน RenderStepped ทุกเฟรม
            -- ลด CPU จาก 60fps → 10fps สำหรับ ESP update
            ConnMgr:AddThrottled(MODULE_NAME, 0.1, function()
                if not RYS.Enabled.ESP then
                    pcall(function() highlight:Destroy() end)
                    pcall(function() billboard:Destroy() end)
                    ConnMgr:DisconnectAll(MODULE_NAME)
                    return
                end
                if not character.Parent or not humanoid or humanoid.Health <= 0 then
                    pcall(function() highlight:Destroy() end)
                    pcall(function() billboard:Destroy() end)
                    return
                end
                local myRoot = RYS.GetRootPart()
                if myRoot and rootPart then
                    local dist = RYS.GetDistance(myRoot.Position, rootPart.Position)
                    distLabel.Text = string.format("[%.0f studs]", dist)
                    healthLabel.Text = string.format("HP: %.0f/%.0f", humanoid.Health, humanoid.MaxHealth)
                end
            end, "Heartbeat") -- ✅ ใช้ Heartbeat แทน RenderStepped
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
            RYS.Notify("ESP", "✅ เปิดแล้ว — เห็นทุกคนทะลุกำแพง!")
        else
            -- ✅ Cleanup connections ก่อน
            ConnMgr:DisconnectAll(MODULE_NAME)
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character then
                    local h = player.Character:FindFirstChild("RYS_ESP")
                    local b = player.Character:FindFirstChild("RYS_ESP_Info")
                    if h then h:Destroy() end
                    if b then b:Destroy() end
                end
            end
            RYS.Notify("ESP", "❌ ปิดแล้ว")
        end
    end

    RYS.RegisterModule("ESP", ESP)
    return ESP
end
