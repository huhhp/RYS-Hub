--[[
    RYS Hub — Floating Toggle Button (Optimized)
    ✅ ใช้ TweenInfo RepeatCount=-1 แทน task.spawn loop
--]]

return function(RYS)
    local CoreGui = RYS.Services.CoreGui
    local TweenService = RYS.Services.TweenService

    local function CreateFloatingButton()
        -- Destroy old
        pcall(function() CoreGui:FindFirstChild("RYS_FloatBtn"):Destroy() end)

        local floatGui = Instance.new("ScreenGui")
        floatGui.Name = "RYS_FloatBtn"
        floatGui.ResetOnSpawn = false
        floatGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        floatGui.DisplayOrder = 999
        floatGui.Parent = CoreGui

        local floatBtn = Instance.new("TextButton")
        floatBtn.Name = "ToggleBtn"
        floatBtn.Size = UDim2.new(0, 50, 0, 50)
        floatBtn.Position = UDim2.new(0, 10, 0.5, -25)
        floatBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 255)
        floatBtn.Text = "⚡"
        floatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        floatBtn.Font = Enum.Font.GothamBold
        floatBtn.TextSize = 22
        floatBtn.Parent = floatGui
        floatBtn.Active = true
        floatBtn.Draggable = true

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(1, 0)
        btnCorner.Parent = floatBtn

        local btnStroke = Instance.new("UIStroke")
        btnStroke.Color = Color3.fromRGB(180, 130, 255)
        btnStroke.Thickness = 2
        btnStroke.Parent = floatBtn

        -- ✅ OPTIMIZED: ใช้ TweenInfo RepeatCount=-1 แทน task.spawn loop
        -- ไม่สร้าง thread ใหม่ ไม่กิน memory
        local pulseTween = TweenService:Create(btnStroke, 
            TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
            { Color = Color3.fromRGB(0, 255, 200) }
        )
        pulseTween:Play()

        floatBtn.MouseButton1Click:Connect(function()
            if RYS.GUI and RYS.GUI.Parent then
                local mainFrame = RYS.GUI:FindFirstChild("MainFrame")
                if mainFrame then
                    mainFrame.Visible = not mainFrame.Visible
                end
            end
        end)

        return floatGui
    end

    return CreateFloatingButton
end
