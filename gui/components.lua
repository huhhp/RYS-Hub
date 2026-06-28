--[[
    RYS Hub — GUI Components v5.0
    
    🎨 Premium UI Design Engine (Glassmorphism & Neon Aura)
    🤖 Micro-Animations & Responsive Control Components
--]]

return function(RYS)
    local Components = {}
    local TweenService = RYS.Services.TweenService
    local UIS = RYS.Services.UserInputService
    local Players = RYS.Services.Players

    -- ═══════════════════════════════════════
    -- RESPONSIVE DICTIONARY
    -- ═══════════════════════════════════════
    Components.Sizes = {
        guiWidth = RYS.IsMobile and 350 or 580,
        guiHeight = RYS.IsMobile and 430 or 600,
        sidebarWidth = RYS.IsMobile and 60 or 150,
        fontSize = RYS.IsMobile and 11 or 13,
        titleSize = RYS.IsMobile and 13 or 16,
        btnHeight = RYS.IsMobile and 36 or 42,
    }
    
    local sizes = Components.Sizes

    -- ═══════════════════════════════════════
    -- HELPER ANIMATION: Press Scale Bounce
    -- ═══════════════════════════════════════
    local function PlayClickBounce(element)
        local origSize = element.Size
        local shrink = UDim2.new(
            origSize.X.Scale * 0.96, origSize.X.Offset * 0.96,
            origSize.Y.Scale * 0.96, origSize.Y.Offset * 0.96
        )
        TweenService:Create(element, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = shrink }):Play()
        task.wait(0.05)
        TweenService:Create(element, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = origSize }):Play()
    end

    -- ═══════════════════════════════════════
    -- TAB BUTTON CREATOR
    -- ═══════════════════════════════════════
    function Components.CreateTabButton(parent, name, emoji, callback, isDefault)
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = name .. "_Tab"
        tabBtn.Size = UDim2.new(1, -10, 0, RYS.IsMobile and 40 or 44)
        tabBtn.BackgroundColor3 = isDefault and Color3.fromRGB(35, 20, 60) or Color3.fromRGB(20, 16, 32)
        tabBtn.BackgroundTransparency = isDefault and 0.2 or 0.7
        tabBtn.Text = ""
        tabBtn.Parent = parent

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = tabBtn

        local btnStroke = Instance.new("UIStroke")
        btnStroke.Color = isDefault and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(55, 45, 80)
        btnStroke.Thickness = 1
        btnStroke.Transparency = isDefault and 0 or 0.5
        btnStroke.Parent = tabBtn

        -- Icon (Emoji) + Text
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = RYS.IsMobile and emoji or (emoji .. "  " .. name)
        textLabel.TextColor3 = isDefault and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 170, 200)
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextSize = sizes.fontSize
        textLabel.TextXAlignment = RYS.IsMobile and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
        textLabel.Position = RYS.IsMobile and UDim2.new(0, 0, 0, 0) or UDim2.new(0, 12, 0, 0)
        textLabel.Parent = tabBtn

        local active = isDefault

        local function SetActive(state)
            active = state
            if active then
                TweenService:Create(tabBtn, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(35, 20, 60),
                    BackgroundTransparency = 0.2
                }):Play()
                TweenService:Create(textLabel, TweenInfo.new(0.2), {
                    TextColor3 = Color3.fromRGB(255, 255, 255)
                }):Play()
                btnStroke.Color = Color3.fromRGB(0, 255, 255)
                btnStroke.Transparency = 0
            else
                TweenService:Create(tabBtn, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(20, 16, 32),
                    BackgroundTransparency = 0.7
                }):Play()
                TweenService:Create(textLabel, TweenInfo.new(0.2), {
                    TextColor3 = Color3.fromRGB(180, 170, 200)
                }):Play()
                btnStroke.Color = Color3.fromRGB(55, 45, 80)
                btnStroke.Transparency = 0.5
            end
        end

        tabBtn.MouseButton1Click:Connect(function()
            task.spawn(PlayClickBounce, tabBtn)
            callback(SetActive)
        end)

        -- Hover effect (PC only)
        if not RYS.IsMobile then
            tabBtn.MouseEnter:Connect(function()
                if not active then
                    TweenService:Create(tabBtn, TweenInfo.new(0.15), {
                        BackgroundColor3 = Color3.fromRGB(35, 25, 60),
                        BackgroundTransparency = 0.5
                    }):Play()
                end
            end)
            tabBtn.MouseLeave:Connect(function()
                if not active then
                    TweenService:Create(tabBtn, TweenInfo.new(0.15), {
                        BackgroundColor3 = Color3.fromRGB(20, 16, 32),
                        BackgroundTransparency = 0.7
                    }):Play()
                end
            end)
        end

        return tabBtn, SetActive
    end

    -- ═══════════════════════════════════════
    -- TOGGLE SWITCH (ON/OFF)
    -- ═══════════════════════════════════════
    function Components.CreateToggleButton(parent, name, emoji, description, defaultState, callback)
        local btn = Instance.new("Frame")
        btn.Name = name .. "_Toggle"
        btn.Size = UDim2.new(1, -10, 0, sizes.btnHeight + 10)
        btn.BackgroundColor3 = Color3.fromRGB(22, 18, 38)
        btn.BackgroundTransparency = 0.3
        btn.BorderSizePixel = 0
        btn.Parent = parent

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 10)
        btnCorner.Parent = btn

        local btnStroke = Instance.new("UIStroke")
        btnStroke.Color = Color3.fromRGB(60, 48, 90)
        btnStroke.Thickness = 1
        btnStroke.Parent = btn

        -- Title & Description Wrapper
        local textContainer = Instance.new("Frame")
        textContainer.Size = UDim2.new(0.7, 0, 1, 0)
        textContainer.Position = UDim2.new(0, 12, 0, 0)
        textContainer.BackgroundTransparency = 1
        textContainer.Parent = btn

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0.5, 5)
        label.Position = UDim2.new(0, 0, 0, 4)
        label.BackgroundTransparency = 1
        label.Text = emoji .. " " .. name
        label.TextColor3 = Color3.fromRGB(230, 230, 245)
        label.Font = Enum.Font.GothamBold
        label.TextSize = sizes.fontSize
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = textContainer

        local descLabel = Instance.new("TextLabel")
        descLabel.Size = UDim2.new(1, 0, 0.5, -5)
        descLabel.Position = UDim2.new(0, 0, 0.5, 2)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = description or "ไม่มีคำอธิบายเพิ่มเติม"
        descLabel.TextColor3 = Color3.fromRGB(140, 130, 160)
        descLabel.Font = Enum.Font.GothamMedium
        descLabel.TextSize = sizes.fontSize - 2
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.Parent = textContainer

        -- Toggle Clicker Area
        local clickBtn = Instance.new("TextButton")
        clickBtn.Size = UDim2.new(1, 0, 1, 0)
        clickBtn.BackgroundTransparency = 1
        clickBtn.Text = ""
        clickBtn.Parent = btn

        -- Switch Graphic (Outer Track)
        local switchTrack = Instance.new("Frame")
        switchTrack.Size = UDim2.new(0, 38, 0, 20)
        switchTrack.Position = UDim2.new(1, -50, 0.5, -10)
        switchTrack.BackgroundColor3 = Color3.fromRGB(40, 30, 60)
        switchTrack.BorderSizePixel = 0
        switchTrack.Parent = btn

        local trackCorner = Instance.new("UICorner")
        trackCorner.CornerRadius = UDim.new(1, 0)
        trackCorner.Parent = switchTrack

        -- Switch Graphic (Inner Knob)
        local switchKnob = Instance.new("Frame")
        switchKnob.Size = UDim2.new(0, 14, 0, 14)
        switchKnob.Position = UDim2.new(0, 3, 0.5, -7)
        switchKnob.BackgroundColor3 = Color3.fromRGB(180, 170, 200)
        switchKnob.BorderSizePixel = 0
        switchKnob.Parent = switchTrack

        local knobCorner = Instance.new("UICorner")
        knobCorner.CornerRadius = UDim.new(1, 0)
        knobCorner.Parent = switchKnob

        local isOn = defaultState or false

        local function UpdateState(state, runCallback)
            isOn = state
            if isOn then
                TweenService:Create(switchTrack, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(138, 43, 226) }):Play() -- Electric Violet
                TweenService:Create(switchKnob, TweenInfo.new(0.2), { 
                    Position = UDim2.new(1, -17, 0.5, -7),
                    BackgroundColor3 = Color3.fromRGB(0, 255, 255) -- Cyan Knob
                }):Play()
                btnStroke.Color = Color3.fromRGB(138, 43, 226)
            else
                TweenService:Create(switchTrack, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(40, 30, 60) }):Play()
                TweenService:Create(switchKnob, TweenInfo.new(0.2), { 
                    Position = UDim2.new(0, 3, 0.5, -7),
                    BackgroundColor3 = Color3.fromRGB(180, 170, 200)
                }):Play()
                btnStroke.Color = Color3.fromRGB(60, 48, 90)
            end
            if runCallback then
                task.spawn(callback, isOn)
            end
        end

        -- บูตสถานะแรก
        UpdateState(isOn, false)

        clickBtn.MouseButton1Click:Connect(function()
            task.spawn(PlayClickBounce, btn)
            UpdateState(not isOn, true)
        end)

        return btn, UpdateState
    end

    -- ═══════════════════════════════════════
    -- ACTION BUTTON (Click trigger)
    -- ═══════════════════════════════════════
    function Components.CreateActionButton(parent, name, emoji, callback)
        local btn = Instance.new("TextButton")
        btn.Name = name .. "_Action"
        btn.Size = UDim2.new(1, -10, 0, sizes.btnHeight)
        btn.BackgroundColor3 = Color3.fromRGB(30, 16, 50)
        btn.BackgroundTransparency = 0.2
        btn.Text = ""
        btn.Parent = parent

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn

        local btnStroke = Instance.new("UIStroke")
        btnStroke.Color = Color3.fromRGB(110, 50, 200)
        btnStroke.Thickness = 1
        btnStroke.Parent = btn

        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = emoji .. "  " .. name
        textLabel.TextColor3 = Color3.fromRGB(220, 200, 255)
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextSize = sizes.fontSize
        textLabel.Parent = textLabel.Parent -- ซ้อนข้างบน
        textLabel.Parent = btn

        btn.MouseButton1Click:Connect(function()
            task.spawn(PlayClickBounce, btn)
            
            -- Click animation glow
            btnStroke.Color = Color3.fromRGB(0, 255, 255)
            TweenService:Create(btn, TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(45, 25, 80) }):Play()
            task.wait(0.1)
            TweenService:Create(btn, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(30, 16, 50) }):Play()
            btnStroke.Color = Color3.fromRGB(110, 50, 200)
            
            task.spawn(callback)
        end)

        -- Hover effect (PC only)
        if not RYS.IsMobile then
            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.15), {
                    BackgroundColor3 = Color3.fromRGB(45, 25, 75),
                    BackgroundTransparency = 0.1
                }):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.15), {
                    BackgroundColor3 = Color3.fromRGB(30, 16, 50),
                    BackgroundTransparency = 0.2
                }):Play()
            end)
        end

        return btn
    end

    -- ═══════════════════════════════════════
    -- SLIDER CREATOR
    -- ═══════════════════════════════════════
    function Components.CreateSlider(parent, name, emoji, min, max, defaultVal, callback)
        local sliderFrame = Instance.new("Frame")
        sliderFrame.Name = name .. "_Slider"
        sliderFrame.Size = UDim2.new(1, -10, 0, sizes.btnHeight + 18)
        sliderFrame.BackgroundColor3 = Color3.fromRGB(22, 18, 38)
        sliderFrame.BackgroundTransparency = 0.3
        sliderFrame.Parent = parent

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = sliderFrame

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(60, 48, 90)
        stroke.Thickness = 1
        stroke.Parent = sliderFrame

        -- Text showing current value
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -20, 0, 22)
        title.Position = UDim2.new(0, 12, 0, 6)
        title.BackgroundTransparency = 1
        title.Text = emoji .. " " .. name .. ": " .. tostring(defaultVal)
        title.TextColor3 = Color3.fromRGB(220, 220, 235)
        title.Font = Enum.Font.GothamBold
        title.TextSize = sizes.fontSize
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = sliderFrame

        -- Slider Track Background
        local track = Instance.new("TextButton")
        track.Size = UDim2.new(1, -24, 0, 6)
        track.Position = UDim2.new(0, 12, 0, 36)
        track.BackgroundColor3 = Color3.fromRGB(40, 30, 60)
        track.BorderSizePixel = 0
        track.Text = ""
        track.Parent = sliderFrame

        local trackCorner = Instance.new("UICorner")
        trackCorner.CornerRadius = UDim.new(1, 0)
        trackCorner.Parent = track

        -- Slider Track Fill
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((defaultVal - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(138, 43, 226) -- Electric Violet
        fill.BorderSizePixel = 0
        fill.Parent = track

        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(1, 0)
        fillCorner.Parent = fill

        -- Knob
        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 14, 0, 14)
        knob.Position = UDim2.new(1, -7, 0.5, -7)
        knob.BackgroundColor3 = Color3.fromRGB(0, 255, 255) -- Cyan Glow
        knob.BorderSizePixel = 0
        knob.Parent = fill

        local knobCorner = Instance.new("UICorner")
        knobCorner.CornerRadius = UDim.new(1, 0)
        knobCorner.Parent = knob

        local activeVal = defaultVal
        local isDragging = false

        local function UpdateSliderValue(inputPos)
            local ratio = math.clamp((inputPos.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            activeVal = math.floor(min + (max - min) * ratio)
            
            title.Text = emoji .. " " .. name .. ": " .. tostring(activeVal)
            TweenService:Create(fill, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
                Size = UDim2.new(ratio, 0, 1, 0)
            }):Play()
            
            task.spawn(callback, activeVal)
        end

        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = true
                stroke.Color = Color3.fromRGB(0, 255, 255)
                UpdateSliderValue(input.Position)
            end
        end)

        UIS.InputChanged:Connect(function(input)
            if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                UpdateSliderValue(input.Position)
            end
        end)

        UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = false
                stroke.Color = Color3.fromRGB(60, 48, 90)
            end
        end)

        return sliderFrame
    end

    -- ═══════════════════════════════════════
    -- SECTION LABEL
    -- ═══════════════════════════════════════
    function Components.CreateSectionLabel(parent, text)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -10, 0, 28)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(150, 120, 240)
        label.Font = Enum.Font.GothamBold
        label.TextSize = sizes.fontSize - 1
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Position = UDim2.new(0, 5, 0, 0)
        label.Parent = parent
        return label
    end

    return Components
end
