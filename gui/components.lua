--[[
    RYS Hub — GUI Components
    ปุ่ม, Section, Toggle creators
    ✅ แยกออกมาเพื่อ reuse
--]]

return function(RYS)
    local Components = {}
    local TweenService = RYS.Services.TweenService

    -- ═══════════════════════════════════════
    -- RESPONSIVE SIZES
    -- ═══════════════════════════════════════
    Components.Sizes = {
        guiWidth = RYS.IsMobile and 320 or 520,
        guiHeight = RYS.IsMobile and 420 or 580,
        fontSize = RYS.IsMobile and 12 or 14,
        titleSize = RYS.IsMobile and 14 or 18,
        btnHeight = RYS.IsMobile and 38 or 45,
    }

    -- ═══════════════════════════════════════
    -- TOGGLE BUTTON (ON/OFF)
    -- ═══════════════════════════════════════
    function Components.CreateToggleButton(parent, name, emoji, description, callback, order)
        local sizes = Components.Sizes

        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Size = UDim2.new(1, -10, 0, sizes.btnHeight)
        btn.BackgroundColor3 = Color3.fromRGB(25, 20, 45)
        btn.BorderSizePixel = 0
        btn.Text = ""
        btn.LayoutOrder = order
        btn.Parent = parent

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn

        local btnStroke = Instance.new("UIStroke")
        btnStroke.Color = Color3.fromRGB(60, 40, 100)
        btnStroke.Thickness = 1
        btnStroke.Parent = btn

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.Position = UDim2.new(0, 15, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = emoji .. "  " .. name
        label.TextColor3 = Color3.fromRGB(220, 220, 240)
        label.Font = Enum.Font.GothamBold
        label.TextSize = sizes.fontSize
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = btn

        local status = Instance.new("TextLabel")
        status.Name = "Status"
        status.Size = UDim2.new(0.25, 0, 1, 0)
        status.Position = UDim2.new(0.75, 0, 0, 0)
        status.BackgroundTransparency = 1
        status.Text = "OFF"
        status.TextColor3 = Color3.fromRGB(255, 80, 80)
        status.Font = Enum.Font.GothamBold
        status.TextSize = sizes.fontSize - 1
        status.Parent = btn

        local isOn = false
        btn.MouseButton1Click:Connect(function()
            isOn = not isOn
            if isOn then
                status.Text = "ON"
                status.TextColor3 = Color3.fromRGB(80, 255, 120)
                btnStroke.Color = Color3.fromRGB(80, 255, 120)
                -- ✅ Smooth transition animation
                TweenService:Create(btn, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(20, 40, 30)
                }):Play()
            else
                status.Text = "OFF"
                status.TextColor3 = Color3.fromRGB(255, 80, 80)
                btnStroke.Color = Color3.fromRGB(60, 40, 100)
                TweenService:Create(btn, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(25, 20, 45)
                }):Play()
            end
            callback(isOn)
        end)

        -- ✅ Hover effect (PC only)
        if not RYS.IsMobile then
            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.15), {
                    BackgroundColor3 = isOn and Color3.fromRGB(25, 50, 35) or Color3.fromRGB(35, 30, 60)
                }):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.15), {
                    BackgroundColor3 = isOn and Color3.fromRGB(20, 40, 30) or Color3.fromRGB(25, 20, 45)
                }):Play()
            end)
        end

        return btn
    end

    -- ═══════════════════════════════════════
    -- ACTION BUTTON (one-shot)
    -- ═══════════════════════════════════════
    function Components.CreateActionButton(parent, name, emoji, callback, order)
        local sizes = Components.Sizes

        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Size = UDim2.new(1, -10, 0, sizes.btnHeight)
        btn.BackgroundColor3 = Color3.fromRGB(35, 15, 60)
        btn.BorderSizePixel = 0
        btn.Text = emoji .. "  " .. name
        btn.TextColor3 = Color3.fromRGB(200, 170, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = sizes.fontSize
        btn.LayoutOrder = order
        btn.Parent = parent

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn

        local btnStroke = Instance.new("UIStroke")
        btnStroke.Color = Color3.fromRGB(100, 50, 200)
        btnStroke.Thickness = 1
        btnStroke.Parent = btn

        btn.MouseButton1Click:Connect(function()
            -- ✅ Click feedback animation
            TweenService:Create(btn, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.fromRGB(60, 30, 100)
            }):Play()
            task.wait(0.1)
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(35, 15, 60)
            }):Play()
            callback()
        end)

        -- ✅ Hover effect (PC only)
        if not RYS.IsMobile then
            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.15), {
                    BackgroundColor3 = Color3.fromRGB(45, 25, 80)
                }):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.15), {
                    BackgroundColor3 = Color3.fromRGB(35, 15, 60)
                }):Play()
            end)
        end

        return btn
    end

    -- ═══════════════════════════════════════
    -- SECTION LABEL
    -- ═══════════════════════════════════════
    function Components.CreateSectionLabel(parent, text, order)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -10, 0, 30)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(130, 100, 220)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.LayoutOrder = order
        label.Parent = parent
        return label
    end

    return Components
end
