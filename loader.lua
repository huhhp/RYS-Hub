--[[
    ██████╗ ██╗   ██╗███████╗    ██╗  ██╗██╗   ██╗██████╗ 
    ██╔══██╗╚██╗ ██╔╝██╔════╝    ██║  ██║██║   ██║██╔══██╗
    ██████╔╝ ╚████╔╝ ███████╗    ███████║██║   ██║██████╔╝
    ██╔══██╗  ╚██╔╝  ╚════██║    ██╔══██║██║   ██║██╔══██╗
    ██║  ██║   ██║   ███████║    ██║  ██║╚██████╔╝██████╔╝
    ╚═╝  ╚═╝   ╚═╝   ╚══════╝    ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ 
    
    RYS Ultimate Hub v4.0 — Made for Wanq
    Modular Architecture — Optimized Performance
    
    ⚡ Execute แค่ไฟล์นี้ไฟล์เดียว!
    ⚠️ ใช้กับ Executor เท่านั้น (Synapse X, Script-Ware, Fluxus, etc.)
--]]

-- ═══════════════════════════════════════
-- CONFIG: เปลี่ยน URL ตรงนี้ให้ตรงกับ Repo ของ Wanq
-- ═══════════════════════════════════════
local REPO_URL = "https://raw.githubusercontent.com/huhhp/RYS-Hub/main/"

-- ═══════════════════════════════════════
-- MODULE LOADER
-- ═══════════════════════════════════════
local loadedModules = {}
local loadErrors = {}

local function LoadModule(path)
    local url = REPO_URL .. path
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    
    if success then
        loadedModules[path] = true
        return result
    else
        table.insert(loadErrors, { path = path, error = tostring(result) })
        warn("[RYS] ❌ โหลดไม่ได้: " .. path .. " — " .. tostring(result))
        return nil
    end
end

-- ═══════════════════════════════════════
-- LOADING SEQUENCE
-- ═══════════════════════════════════════
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("   ⚡ RYS ULTIMATE HUB v4.0 — Loading...     ")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

-- Step 1: Core
print("📦 [1/4] Loading Core...")
local RYS = LoadModule("core/init.lua")
if not RYS then
    error("[RYS] ❌ Fatal: ไม่สามารถโหลด Core ได้!")
    return
end

local ConnMgr = LoadModule("core/connection.lua")
if not ConnMgr then
    error("[RYS] ❌ Fatal: ไม่สามารถโหลด Connection Manager ได้!")
    return
end

-- Step 2: All Modules
print("🔧 [2/4] Loading Modules...")
local moduleFiles = {
    -- Combat
    "modules/combat/esp.lua",
    "modules/combat/aimbot.lua",
    "modules/combat/killaura.lua",
    "modules/combat/hitbox.lua",
    -- Movement
    "modules/movement/fly.lua",
    "modules/movement/speed.lua",
    "modules/movement/noclip.lua",
    "modules/movement/infjump.lua",
    "modules/movement/freecam.lua",
    -- Defense
    "modules/defense/godmode.lua",
    "modules/defense/invisible.lua",
    "modules/defense/antikick.lua",
    "modules/defense/antiafk.lua",
    "modules/defense/anticheat.lua",
    -- Exploit
    "modules/exploit/remotespy.lua",
    "modules/exploit/autofarm.lua",
    "modules/exploit/valuemod.lua",
    "modules/exploit/serverhop.lua",
    "modules/exploit/bringall.lua",
    "modules/exploit/chatspam.lua",
    "modules/exploit/fovchanger.lua",
}

local loadedCount = 0
for _, path in ipairs(moduleFiles) do
    local moduleInit = LoadModule(path)
    if moduleInit and type(moduleInit) == "function" then
        local ok, err = pcall(function()
            moduleInit(RYS, ConnMgr)
        end)
        if ok then
            loadedCount = loadedCount + 1
            print("   ✅ " .. path)
        else
            warn("   ❌ " .. path .. " — Init error: " .. tostring(err))
        end
    end
end
print(string.format("   📋 Loaded: %d/%d modules", loadedCount, #moduleFiles))

-- Step 3: GUI
print("🎨 [3/4] Loading GUI...")
local Components = LoadModule("gui/components.lua")
if Components and type(Components) == "function" then
    Components = Components(RYS)
end

local CreateFloatingButton = LoadModule("gui/floating.lua")
if CreateFloatingButton and type(CreateFloatingButton) == "function" then
    CreateFloatingButton = CreateFloatingButton(RYS)
end

local CreateGUI = LoadModule("gui/main.lua")
if CreateGUI and type(CreateGUI) == "function" then
    CreateGUI = CreateGUI(RYS, Components)
end

-- Step 4: Initialize
print("🚀 [4/4] Initializing...")

-- สร้าง Floating Button
if CreateFloatingButton and type(CreateFloatingButton) == "function" then
    CreateFloatingButton()
end

-- สร้าง GUI
if CreateGUI and type(CreateGUI) == "function" then
    CreateGUI()
end

-- Hotkey (PC only)
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

-- ═══════════════════════════════════════
-- FINAL STATUS
-- ═══════════════════════════════════════
local platform = RYS.IsMobile and "📱 Mobile" or "💻 PC"
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("   ⚡ RYS ULTIMATE HUB v4.0 — Loaded!       ")
print("   Made for Wanq by RYS                      ")
print("   Platform: " .. platform)
print(string.format("   📋 Modules: %d/%d loaded", loadedCount, #moduleFiles))
if #loadErrors > 0 then
    print("   ⚠️ Errors: " .. #loadErrors)
    for _, err in ipairs(loadErrors) do
        print("      ❌ " .. err.path)
    end
end
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

if RYS.IsMobile then
    print("   📱 กดปุ่ม ⚡ เพื่อเปิด/ปิด GUI           ")
    RYS.Notify("RYS Hub", "⚡ v4.0 📱 Mobile Mode! กดปุ่ม ⚡ เปิด/ปิด")
else
    print("   🎮 RightShift หรือกดปุ่ม ⚡ เปิด/ปิด GUI  ")
    RYS.Notify("RYS Hub", "⚡ v4.0 โหลดสำเร็จ! RightShift หรือกดปุ่ม ⚡")
end
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

-- ═══════════════════════════════════════
-- GLOBAL ACCESS (สำหรับ console commands)
-- ═══════════════════════════════════════
if getgenv then
    getgenv().RYS = RYS
    getgenv().ConnMgr = ConnMgr
end

return RYS
