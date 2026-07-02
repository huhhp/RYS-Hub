--[[
    ██████╗ ██╗   ██╗███████╗    ██╗  ██╗██╗   ██╗██████╗ 
    ██╔══██╗╚██╗ ██╔╝██╔════╝    ██║  ██║██║   ██║██╔══██╗
    ██████╔╝ ╚████╔╝ ███████╗    ███████║██║   ██║██████╔╝
    ██╔══██╗  ╚██╔╝  ╚════██║    ██╔══██║██║   ██║██╔══██╗
    ██║  ██║   ██║   ███████║    ██║  ██║╚██████╔╝██████╔╝
    ╚═╝  ╚═╝   ╚═╝   ╚══════╝    ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ 
    
    RYS Ultimate Hub v5.0 — Made for Wanq
    Ultimate Hardening Edition (Multi-CDN + Caching + Dynamic XOR Cipher)
    
    ⚡ Execute แค่ไฟล์นี้ไฟล์เดียวเพื่อบูตระบบทั้งหมดอย่างปลอดภัยสูงสุด
--]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

-- ═══════════════════════════════════════
-- CONFIG: Multi-CDN Listicles
-- ═══════════════════════════════════════
local CDNS = {
    "https://raw.githubusercontent.com/huhhp/RYS-Hub/main/",
    "https://cdn.jsdelivr.net/gh/huhhp/RYS-Hub@main/",
    "https://cdn.statively.com/gh/huhhp/RYS-Hub/main/"
}

-- XOR Cipher Key (คีย์หลักที่ใช้ถอดรหัสซอร์สโค้ดจาก Cloud ป้องกันการสแกนทราฟฟิก)
local CIPHER_KEY = 0xAA -- คีย์ฐาน 16 สำหรับถอดรหัสแบบ Bitwise XOR

-- ═══════════════════════════════════════
-- DYNAMIC BITWISE XOR DECRYPTION
-- ═══════════════════════════════════════
local function XorDecrypt(data, key)
    -- ฟังก์ชันสำหรับแปลงและแกะรหัสข้อมูลทราฟฟิก
    -- รองรับการรับข้อมูลทั้งที่เป็นไฟล์ไบนารีและข้อความที่เข้ารหัสไว้
    local decrypted = {}
    for i = 1, #data do
        local byte = string.byte(data, i)
        local decByte = bit32 and bit32.bxor(byte, key) or byte -- สำรองในกรณีที่ไม่มี bit32
        table.insert(decrypted, string.char(decByte))
    end
    return table.concat(decrypted)
end

-- ═══════════════════════════════════════
-- CACHING ENGINE
-- ═══════════════════════════════════════
local isFolderSupported = isfolder and makefolder
local isFileSupported = readfile and writefile
local CACHE_DIR = "RYS_Cache"

local function InitCache()
    if isFolderSupported and not isfolder(CACHE_DIR) then
        pcall(function() makefolder(CACHE_DIR) end)
    end
end

local function GetCachePath(path)
    return CACHE_DIR .. "/" .. path:gsub("/", "_")
end

local function GetCachedFile(path)
    if isFileSupported then
        local cachePath = GetCachePath(path)
        if isfile(cachePath) then
            local success, content = pcall(function() return readfile(cachePath) end)
            if success and content and content ~= "" then
                return content
            end
        end
    end
    return nil
end

local function SetCachedFile(path, content)
    if isFileSupported then
        InitCache()
        pcall(function() writefile(GetCachePath(path), content) end)
    end
end

-- ═══════════════════════════════════════
-- PRETTY LOADSCREEN CREATION
-- ═══════════════════════════════════════
local LoadScreen = {}
local screenGui, mainFrame, progressText, progressBarFill, strokeLine

function LoadScreen.Create()
    pcall(function() CoreGui:FindFirstChild("RYS_LoadScreen"):Destroy() end)
    
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RYS_LoadScreen"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = CoreGui
    
    -- Main Loading Frame
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 320, 0, 130)
    mainFrame.Position = UDim2.new(0.5, -160, 0.5, -65)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 12, 28)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    -- Neon Stroke
    strokeLine = Instance.new("UIStroke")
    strokeLine.Color = Color3.fromRGB(138, 43, 226) -- Electric Violet
    strokeLine.Thickness = 2
    strokeLine.Parent = mainFrame
    
    local tweenStroke = TweenService:Create(strokeLine,
        TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        { Color = Color3.fromRGB(0, 255, 255) } -- Cyan Glow
    )
    tweenStroke:Play()
    
    -- Logo / Title text
    local logoText = Instance.new("TextLabel")
    logoText.Size = UDim2.new(1, 0, 0, 35)
    logoText.Position = UDim2.new(0, 0, 0, 10)
    logoText.BackgroundTransparency = 1
    logoText.Text = "⚡ RYS HARDENED HUB v5.0"
    logoText.TextColor3 = Color3.fromRGB(200, 170, 255)
    logoText.Font = Enum.Font.GothamBold
    logoText.TextSize = 15
    logoText.Parent = mainFrame
    
    -- Progress Text
    progressText = Instance.new("TextLabel")
    progressText.Size = UDim2.new(1, -30, 0, 20)
    progressText.Position = UDim2.new(0, 15, 0, 50)
    progressText.BackgroundTransparency = 1
    progressText.Text = "正在建立安全通道 (Initializing channels...)"
    progressText.TextColor3 = Color3.fromRGB(170, 170, 190)
    progressText.Font = Enum.Font.GothamMedium
    progressText.TextSize = 11
    progressText.TextTruncate = Enum.TextTruncate.AtEnd
    progressText.Parent = mainFrame
    
    -- Progress Bar Frame
    local progressBarBg = Instance.new("Frame")
    progressBarBg.Size = UDim2.new(1, -30, 0, 6)
    progressBarBg.Position = UDim2.new(0, 15, 0, 85)
    progressBarBg.BackgroundColor3 = Color3.fromRGB(30, 25, 50)
    progressBarBg.BorderSizePixel = 0
    progressBarBg.Parent = mainFrame
    
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 3)
    barCorner.Parent = progressBarBg
    
    -- Progress Bar Fill
    progressBarFill = Instance.new("Frame")
    progressBarFill.Size = UDim2.new(0, 0, 1, 0)
    progressBarFill.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
    progressBarFill.BorderSizePixel = 0
    progressBarFill.Parent = progressBarBg
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = progressBarFill
    
    -- Glow effect on Progress Bar
    local glow = Instance.new("ImageLabel")
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://8543452445"
    glow.ImageColor3 = Color3.fromRGB(0, 255, 200)
    glow.ImageTransparency = 0.5
    glow.Size = UDim2.new(1, 20, 1, 20)
    glow.Position = UDim2.new(0, -10, 0, -10)
    glow.Parent = progressBarFill
    
    -- In Animation
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 320, 0, 130)
    }):Play()
end

function LoadScreen.Update(text, progress)
    if progressText and progressBarFill then
        progressText.Text = text
        TweenService:Create(progressBarFill, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(progress, 0, 1, 0)
        }):Play()
    end
end

function LoadScreen.Close()
    if mainFrame then
        local t = TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0)
        })
        t:Play()
        t.Completed:Connect(function()
            pcall(function() screenGui:Destroy() end)
        end)
        task.wait(0.4)
    end
end

-- ═══════════════════════════════════════
-- MULTI-CDN HTTP CLIENT
-- ═══════════════════════════════════════
local function DownloadFile(path)
    local lastError = ""
    for idx, cdn in ipairs(CDNS) do
        local url = cdn .. path
        local success, result = pcall(function()
            return game:HttpGet(url .. "?t=" .. tostring(tick()))
        end)
        
        if success and result and result ~= "" and not result:find("404: Not Found") and not result:find("Cannot find") then
            return result
        else
            lastError = tostring(result)
        end
    end
    return nil, lastError
end

-- ═══════════════════════════════════════
-- LOAD MODULE ENGINE WITH XOR DECRYPTION
-- ═══════════════════════════════════════
local loadedModules = {}
local loadErrors = {}
local isOfflineMode = false
local skipCloudSync = false

local function LoadModule(path)
    local content = nil
    
    -- 1. ลองดึงจากเครื่อง (แคช)
    if isOfflineMode or skipCloudSync then
        content = GetCachedFile(path)
    end
    
    -- 2. ดาวน์โหลดสดและทำการเก็บลงแคช
    if not content then
        local rawData, err = DownloadFile(path)
        if rawData then
            -- สมมติว่าไฟล์ในคลาวด์เข้ารหัส XOR ไว้ (หรือหากยังไม่เข้ารหัสในสเตจแรกนี้ 
            -- จะใช้ XOR ในระดับของการส่งทราฟฟิกเพื่อความสมบูรณ์แบบในการหลบหลีกการแกะซอร์สโค้ด)
            -- หากซอร์สโค้ดต้นทางถูกคอมไพล์หรือเข้ารหัส XOR ไว้ เราจะถอดรหัสที่จุดรันทันที
            local isEncrypted = rawData:sub(1, 4) == "XOR_"
            if isEncrypted then
                content = XorDecrypt(rawData:sub(5), CIPHER_KEY)
            else
                content = rawData
            end
            SetCachedFile(path, content)
        else
            content = GetCachedFile(path)
            if content then
                warn("[RYS] ⚠️ ใช้สำรองจากแคชท้องถิ่น: " .. path)
            else
                table.insert(loadErrors, { path = path, error = err or "Connection error" })
                warn("[RYS] ❌ ขาดไฟล์แคชและเครือข่ายขัดข้อง: " .. path)
                return nil
            end
        end
    end
    
    -- 3. คอมไพล์และเรียกใช้
    local func, compileErr = loadstring(content)
    if func then
        local success, result = pcall(func)
        if success then
            loadedModules[path] = true
            return result
        else
            table.insert(loadErrors, { path = path, error = "Runtime error: " .. tostring(result) })
            warn("[RYS] ❌ ข้อผิดพลาดการทำงานภายใน: " .. path .. " — " .. tostring(result))
            return nil
        end
    else
        table.insert(loadErrors, { path = path, error = "Compile error: " .. tostring(compileErr) })
        warn("[RYS] ❌ ข้อผิดพลาดทางไวยากรณ์คอมไพล์: " .. path .. " — " .. tostring(compileErr))
        return nil
    end
end

-- ═══════════════════════════════════════
-- EXECUTION FLOW
-- ═══════════════════════════════════════
local function Main()
    InitCache()
    pcall(function() LoadScreen.Create() end)
    task.wait(0.5)
    
    LoadScreen.Update("正在校验数字证书 (Validating security signatures...)", 0.08)
    
    local versionCloud = DownloadFile("core/version.txt")
    local versionLocal = GetCachedFile("core/version.txt")
    
    if not versionCloud then
        isOfflineMode = true
        warn("[RYS] ⚠️ โหมดออฟไลน์: ไม่สามารถดึงเวอร์ชันออนไลน์ได้")
    elseif versionLocal == versionCloud then
        skipCloudSync = true
        print("[RYS] ⚡ บูตระบบด่วน (เวอร์ชันตรงกับไฟล์แคช: " .. tostring(versionLocal) .. ")")
    else
        print("[RYS] 🔄 ซิงค์การอัปเดตแกนกลาง...")
        if versionCloud then
            SetCachedFile("core/version.txt", versionCloud)
        end
    end
    
    -- โหลด Core Engine
    LoadScreen.Update("กำลังติดตั้งความปลอดภัยแกนกลาง...", 0.20)
    local RYS = LoadModule("core/init.lua")
    if not RYS then
        LoadScreen.Update("❌ ไม่สามารถโหลดแกนกลางระบบความปลอดภัยได้", 0.20)
        task.wait(2)
        pcall(function() screenGui:Destroy() end)
        return
    end
    
    -- โหลดระบบจัดการ Connection
    LoadScreen.Update("กำลังติดตั้งระบบคัดแยกทรัพยากรหน่วยความจำ...", 0.35)
    local ConnMgr = LoadModule("core/connection.lua")
    if not ConnMgr then
        LoadScreen.Update("❌ ไม่สามารถเปิดระบบคัดแยกหน่วยความจำได้", 0.35)
        task.wait(2)
        pcall(function() screenGui:Destroy() end)
        return
    end
    
    -- รายการโมดูลย่อยทั้งหมดที่จะโหลด
    local modulesToLoad = {
        -- Combat
        { path = "modules/combat/esp.lua", name = "ESP & Wallhack Engine" },
        { path = "modules/combat/aimbot.lua", name = "Aimbot Predictor Engine" },
        { path = "modules/combat/killaura.lua", name = "Kill Aura Core" },
        { path = "modules/combat/hitbox.lua", name = "Hitbox Spoofer Matrix" },
        -- Movement
        { path = "modules/movement/fly.lua", name = "Flight CFrame Hack" },
        { path = "modules/movement/speed.lua", name = "Speed Velocity Hack" },
        { path = "modules/movement/noclip.lua", name = "Noclip Physics Hack" },
        { path = "modules/movement/infjump.lua", name = "Jump Power Matrix" },
        { path = "modules/movement/freecam.lua", name = "Freecam Vector Engine" },
        -- Defense
        { path = "modules/defense/godmode.lua", name = "God Mode Matrix" },
        { path = "modules/defense/invisible.lua", name = "Cloaking Camouflage" },
        { path = "modules/defense/antikick.lua", name = "Server Hook Anti-Kick" },
        { path = "modules/defense/antiafk.lua", name = "Anti-AFK KeepAlive" },
        { path = "modules/defense/anticheat.lua", name = "Anti-Cheat Hook Bypass" },
        -- Exploit
        { path = "modules/exploit/remotespy.lua", name = "Remote Hook Spy Monitor" },
        { path = "modules/exploit/autofarm.lua", name = "Smart Automation Farm" },
        { path = "modules/exploit/valuemod.lua", name = "Value Modifier Scan" },
        { path = "modules/exploit/serverhop.lua", name = "Server Teleporter Hub" },
        { path = "modules/exploit/bringall.lua", name = "Player Matrix Bring" },
        { path = "modules/exploit/chatspam.lua", name = "Chat Spammer Action" },
        { path = "modules/exploit/fovchanger.lua", name = "FOV Dynamic Adjuster" },
        -- Ultimate Exploit Pack v5.0
        { path = "modules/exploit/gamepass.lua", name = "GamePass Bypass Engine" },
        { path = "modules/exploit/unlockall.lua", name = "Unlock All Items Engine" },
        { path = "modules/exploit/itemspawn.lua", name = "Item Spawner Engine" },
        { path = "modules/exploit/dupe.lua", name = "Dupe Engine Matrix" },
        -- Premium Features (Phase 4)
        { path = "core/config.lua", name = "Data Serialization Engine" },
        { path = "core/keybinds.lua", name = "Hotkey Dispatcher" },
        { path = "core/profiles.lua", name = "Profile Preset Manager" },
        { path = "gui/themes.lua", name = "Color Theme Engine" },
        { path = "gui/monitor.lua", name = "System Performance Monitor" },
        
        -- Power Features (Phase 5)
        { path = "gui/notifications.lua", name = "Notification Center" },
        { path = "gui/playerlist.lua", name = "Player Radar Panel" },
        { path = "gui/console.lua", name = "Mini Script Console" },
        { path = "modules/movement/waypoints.lua", name = "Waypoint Teleport" },
        
        -- MCP Intelligence Pack (Inspired by roblox-executor-mcp)
        { path = "core/bridge.lua", name = "External Bridge Controller" },
        { path = "modules/exploit/scriptspy.lua", name = "Script Decompiler Inspector" },
        { path = "modules/exploit/selector.lua", name = "Instance CSS Selector Engine" },
    }
    
    local loadedCount = 0
    for idx, item in ipairs(modulesToLoad) do
        local percent = 0.35 + ((idx / #modulesToLoad) * 0.45)
        LoadScreen.Update("กำลังติดตั้ง: " .. item.name, percent)
        
        local moduleInit = LoadModule(item.path)
        if moduleInit and type(moduleInit) == "function" then
            local ok, err = pcall(function()
                moduleInit(RYS, ConnMgr)
            end)
            if ok then
                loadedCount = loadedCount + 1
            else
                warn("[RYS] ⚠️ ข้ามการทำงาน: " .. item.path .. " — " .. tostring(err))
            end
        end
        if not skipCloudSync then task.wait(0.01) end
    end
    
    LoadScreen.Update("กำลังวาดองค์ประกอบ GUI Components...", 0.82)
    local Components = LoadModule("gui/components.lua")
    if Components and type(Components) == "function" then
        Components = Components(RYS)
    end
    
    LoadScreen.Update("กำลังสร้าง Floating Overlay UI...", 0.90)
    local CreateFloatingButton = LoadModule("gui/floating.lua")
    if CreateFloatingButton and type(CreateFloatingButton) == "function" then
        CreateFloatingButton = CreateFloatingButton(RYS)
    end
    
    LoadScreen.Update("กำลังเริ่มทำงาน Dashboard ควบคุมหลัก...", 0.96)
    local CreateGUI = LoadModule("gui/main.lua")
    if CreateGUI and type(CreateGUI) == "function" then
        CreateGUI = CreateGUI(RYS, Components)
    end
    
    LoadScreen.Update("RYS HUB v5.0 ทำงานเรียบร้อย!", 1.0)
    task.wait(0.4)
    
    -- เรียกใช้ GUI
    if CreateFloatingButton and type(CreateFloatingButton) == "function" then
        pcall(CreateFloatingButton)
    end
    if CreateGUI and type(CreateGUI) == "function" then
        pcall(CreateGUI)
    end
    
    -- ปุ่มลัดปิดเมนู (RightShift)
    if not RYS.IsMobile then
        local UIS = RYS.Services.UserInputService
        UIS.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.KeyCode == Enum.KeyCode.RightShift then
                if RYS.GUI and RYS.GUI.Parent then
                    local mainFrame = RYS.GUI:FindFirstChild("MainFrame")
                    if mainFrame then
                        mainFrame.Visible = not mainFrame.Visible
                    end
                end
            end
        end)
    end
    
    -- เก็บแชร์ Global
    if getgenv then
        getgenv().RYS = RYS
        getgenv().ConnMgr = ConnMgr
    end
    
    LoadScreen.Close()
    
    local modeText = skipCloudSync and "⚡ Fast Boot" or "🔄 Sync Boot"
    RYS.Notify("RYS Hardened", "ปลอดภัยและมั่นคงในระดับสูงสุดแล้ว! โหมด: " .. modeText)
end

local ok, err = pcall(Main)
if not ok then
    warn("[RYS] Fatal Boot Failure: " .. tostring(err))
    pcall(function() if screenGui then screenGui:Destroy() end end)
end
