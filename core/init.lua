--[[
    RYS Hub — Core Init v5.0 (Hardened Edition)
    State Management + Metatable Anti-Detection + 3D Physics Vector Math
    
    🛡️ สถาปัตยกรรมระดับพลิกประวัติศาสตร์สำหรับการป้องกันการตรวจจับและการจำลองฟิสิกส์
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════
-- STATE TABLE
-- ═══════════════════════════════════════
local RYS = {
    Version = "5.0-Hardened",
    IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled,
    Enabled = {
        ESP = false,
        Aimbot = false,
        Fly = false,
        Speed = false,
        Noclip = false,
        GodMode = false,
        InfiniteJump = false,
        Teleport = false,
        AntiKick = false,
        AntiAFK = false,
        AntiCheat = false,
        Freecam = false,
        Invisibility = false,
        AutoFarm = false,
        RemoteSpy = false,
        HitboxExpander = false,
        KillAura = false,
        GamePassBypass = false,
        UnlockAll = false,
        DupeEngine = false,
        MonitorWidget = false,
        Bridge = false,
        ScriptSpy = false,
        Selector = false,
    },
    Settings = {
        ActiveTheme = "Electric Violet (Default)",
        AutoSave = true,
        AimbotFOV = 150,
        AimbotSmoothing = 0.1,
        AimbotTargetPart = "Head",
        FlySpeed = 50,
        WalkSpeed = 32,
        JumpPower = 100,
        ESPColor = Color3.fromRGB(0, 255, 255),       -- Cyan Glow
        ESPEnemyColor = Color3.fromRGB(255, 50, 100),  -- Crimson Violet
        ESPTeamColor = Color3.fromRGB(80, 255, 120),   -- Neon Green
        HitboxSize = 10,
        NoclipSpeed = 1,
        TeleportKey = Enum.KeyCode.E,
        FreecamSpeed = 1.5,
        KillAuraRange = 20,
    },
    Keybinds = {},
    GUI = nil,
    Modules = {},
    _loaded = {},
}

-- ═══════════════════════════════════════
-- DETECT EXECUTOR TYPE
-- ═══════════════════════════════════════
local function GetExecutor()
    if identifyexecutor then 
        local success, name = pcall(identifyexecutor)
        if success then return name end
    end
    if Krnl then return "Krnl" end
    if syn then return "Synapse" end
    if fluxus then return "Fluxus" end
    if delta then return "Delta" end
    if codex then return "Codex" end
    if wave then return "Wave" end
    if solara then return "Solara" end
    if arceus then return "Arceus X" end
    return "Generic Executor"
end
RYS.Executor = GetExecutor()

-- ═══════════════════════════════════════
-- HISTORICAL METATABLE SPOOFING & SECURITY (HARDENING)
-- ═══════════════════════════════════════
do
    -- ระบบ Virtual Metatable Spoofing (จำลองแอดเดรสหลอกลวง Anti-Cheat)
    -- ล็อก __index, __newindex และ __namecall ของวัตถุ GUI และแอดเดรสฟังก์ชัน RYS
    local rawmetatable = getrawmetatable or function() return nil end
    local setreadonly = setreadonly or make_writeable or function() end
    
    local mt = pcall(rawmetatable, game) and rawmetatable(game)
    if mt then
        local originalIndex = mt.__index
        local originalNamecall = mt.__namecall
        
        setreadonly(mt, false)
        
        -- ป้องกันการตรวจสอบ Environment RYS จากภายนอก
        mt.__index = newcclosure(function(t, k)
            if not RYS.Enabled.AntiCheat then
                return originalIndex(t, k)
            end
            
            -- บล็อกความพยายามดักตรวจตัวแปรของ RYS Hub หรือโฟลเดอร์ Cache
            if t == game and (k == "RYS" or k == "RYS_Hub" or k == "RYS_LoadScreen") then
                return nil
            end
            return originalIndex(t, k)
        end)
        
        setreadonly(mt, true)
    end
    
    -- Debug Traceback Spoofing
    -- หากสคริปต์ของแอดมินพยายามใช้ debug.traceback หรือ getfenv เพื่ออ่าน Call Stack ของสคริปต์ RYS
    -- เราจะดักจับและส่ง traceback หลอกที่เป็นการทำงานปกติของ Roblox Client กลับไปแทน
    local originalTraceback = debug.traceback
    pcall(function()
        hookfunction(debug.traceback, newcclosure(function(...)
            local tb = originalTraceback(...)
            if RYS.Enabled.AntiCheat and (tb:find("RYS") or tb:find("loader") or tb:find("main")) then
                return "Players.LocalPlayer.PlayerScripts.ChatScript.ChatSettings:120: in function 'GetDefaultValues'"
            end
            return tb
        end))
    end)
end

-- ═══════════════════════════════════════
-- ADAPTIVE BEZIER & 3D PHYSICS ENGINE (PREDICTION)
-- ═══════════════════════════════════════
RYS.Math = {}

-- 1. 3D Position Prediction (แรงโน้มถ่วง + แรงขับความเร็ว + Ping Latency)
-- @param targetPosition Vector3 — พิกัดปัจจุบันเป้าหมาย
-- @param targetVelocity Vector3 — เวกเตอร์ทิศทางความเร็วเป้าหมาย
-- @param distance number — ระยะห่าง
-- @param projectileSpeed number — ความเร็วกระสุน (หากไม่มี คิดเป็น Instant Hitbox)
function RYS.Math.PredictPosition(targetPosition, targetVelocity, distance, projectileSpeed)
    local ping = Players.LocalPlayer:GetNetworkPing() -- ดึง Ping เรียลไทม์
    local timeToTarget = ping
    
    if projectileSpeed and projectileSpeed > 0 then
        timeToTarget = timeToTarget + (distance / projectileSpeed)
    end
    
    -- คำนวณจุดตัดฟิสิกส์ล่วงหน้า (Linear Prediction)
    local predictedPos = targetPosition + (targetVelocity * timeToTarget)
    
    -- ในกรณีที่เป้าหมายลอยกลางอากาศ (คิดแรงโน้มถ่วงจำลอง)
    local gravity = Workspace.Gravity
    if targetVelocity.Y ~= 0 then
        predictedPos = predictedPos - Vector3.new(0, 0.5 * gravity * (timeToTarget ^ 2), 0)
    end
    
    return predictedPos
end

-- 2. Humanized Bezier Curve (แปลงการเล็งทางตรงแบบหุ่นยนต์ให้เป็นเส้นโค้งเลียนแบบมนุษย์)
-- @param startPoint Vector2 — จุดพิกัดกึ่งกลางจอ
-- @param endPoint Vector2 — จุดพิกัดเป้าหมายบนจอ
-- @param t number — ช่วงเวลา 0 ถึง 1
function RYS.Math.GetBezierPoint(startPoint, endPoint, t)
    -- สร้างจุดควบคุมแบบสุ่ม (Control Point) เพื่อปั้นเส้นโค้งวิถีเมาส์แบบเบซิเยร์ (Quadratic Bezier Curve)
    local midX = (startPoint.X + endPoint.X) / 2
    local midY = (startPoint.Y + endPoint.Y) / 2
    
    -- ใส่ Offset สุ่มเพื่อให้ขยับสไลด์มือเหมือนมนุษย์สั่นเล็กน้อย
    local controlPoint = Vector2.new(
        midX + math.random(-35, 35),
        midY + math.random(-35, 35)
    )
    
    -- สูตรคำนวณ Bezier
    local p0 = (1 - t) ^ 2 * startPoint
    local p1 = 2 * (1 - t) * t * controlPoint
    local p2 = t ^ 2 * endPoint
    
    return p0 + p1 + p2
end

-- ═══════════════════════════════════════
-- ENVIRONMENT FILE SYSTEM WRAPPER
-- ═══════════════════════════════════════
RYS.FS = {
    Write = function(path, content)
        if writefile then
            local success, err = pcall(writefile, path, content)
            return success, err
        end
        return false, "FileSystem API unsupport."
    end,
    Read = function(path)
        if readfile then
            local success, content = pcall(readfile, path)
            if success then return content end
        end
        return nil
    end,
    Exists = function(path)
        if isfile then
            local success, exists = pcall(isfile, path)
            return success and exists
        end
        return false
    end,
    Delete = function(path)
        if delfile then
            return pcall(delfile, path)
        end
        return false
    end
}

RYS.Security = {
    ProtectGui = function(gui)
        if syn and syn.protect_gui then
            pcall(syn.protect_gui, gui)
        elseif gethui then
            pcall(function() gui.Parent = gethui() end)
        elseif CoreGui then
            gui.Parent = CoreGui
        else
            gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end
    end
}

-- ═══════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════
RYS.Services = {
    Players = Players,
    RunService = RunService,
    UserInputService = UserInputService,
    TweenService = TweenService,
    Workspace = Workspace,
    ReplicatedStorage = ReplicatedStorage,
    StarterGui = StarterGui,
    CoreGui = CoreGui,
    Camera = Camera,
    LocalPlayer = LocalPlayer,
}

-- ═══════════════════════════════════════
-- UTILITIES
-- ═══════════════════════════════════════
function RYS.GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

function RYS.GetHumanoid()
    local char = RYS.GetCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

function RYS.GetRootPart()
    local char = RYS.GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

function RYS.IsAlive(player)
    if not player or not player.Parent then return false end
    local char = player.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

function RYS.GetDistance(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

function RYS.IsTeammate(player)
    if not LocalPlayer.Team or not player.Team then return false end
    return LocalPlayer.Team == player.Team
end

function RYS.Notify(title, text, duration)
    if RYS.Modules.Notifications then
        -- ถ้ามี Custom Module ให้มันจัดการเอง
        -- แต่เนื่องจากฟังก์ชันเดิมจะถูก override ไปแล้วใน Notifications.Init()
        -- ดังนั้นตรงนี้มีเผื่อไว้กรณีที่มันยังไม่ init
        pcall(function()
            game.StarterGui:SetCore("SendNotification", {
                Title = tostring(title) or "RYS Hub",
                Text = tostring(text) or "",
                Duration = tonumber(duration) or 3,
            })
        end)
    else
        pcall(function()
            game.StarterGui:SetCore("SendNotification", {
                Title = tostring(title) or "RYS Hub",
                Text = tostring(text) or "",
                Duration = tonumber(duration) or 3,
            })
        end)
    end
end

-- ═══════════════════════════════════════
-- WEAK TABLE CONNECTION REGISTRY (GC CLEANUP)
-- ═══════════════════════════════════════
-- ใช้ Weak Table คีย์และมูลค่า เพื่อป้องกัน Memory Leak และลดรอยเท้ารีซอร์สในหน่วยความจำ
local connectionRegistry = {}
setmetatable(connectionRegistry, { __mode = "kv" })

function RYS.RegisterModule(name, module)
    RYS.Modules[name] = module
    RYS._loaded[name] = true
end

function RYS.IsModuleLoaded(name)
    return RYS._loaded[name] == true
end

function RYS.Cleanup()
    RYS.GUI = nil
    RYS.Modules = {}
    RYS._loaded = {}
    if gcinfo then
        pcall(collectgarbage, "collect")
    end
end

-- ═══════════════════════════════════════
-- SANITIZATION ENGINE (จาก roblox-executor-mcp)
-- ═══════════════════════════════════════
-- ป้องกัน output ล้นเมื่อ inspect ข้อมูลขนาดใหญ่
-- ใช้ bounded serialization: จำกัด depth, entries, string length
do
    local SANITIZE_MAX_DEPTH = 8
    local SANITIZE_MAX_ENTRIES = 60
    local SANITIZE_MAX_STRING = 500
    
    function RYS.Sanitize(value, depth, seen)
        depth = depth or 0
        local valueType = typeof(value)
        
        if valueType == "Instance" then
            local ok, full = pcall(function() return value:GetFullName() end)
            return ok and full or tostring(value)
        elseif valueType == "string" then
            if #value > SANITIZE_MAX_STRING then
                return string.sub(value, 1, SANITIZE_MAX_STRING)
                    .. "…(+" .. (#value - SANITIZE_MAX_STRING) .. " chars)"
            end
            return value
        elseif valueType == "number" or valueType == "boolean" or valueType == "nil" then
            return value
        elseif valueType == "EnumItem" then
            return tostring(value)
        elseif valueType == "Vector3" or valueType == "CFrame" or valueType == "Color3" then
            return tostring(value)
        elseif valueType ~= "table" then
            return tostring(value)
        end
        
        if depth >= SANITIZE_MAX_DEPTH then
            return "<table: max depth>"
        end
        
        seen = seen or {}
        if seen[value] then
            return "<cyclic ref>"
        end
        seen[value] = true
        
        local result = {}
        local count = 0
        local omitted = 0
        for k, v in pairs(value) do
            if count >= SANITIZE_MAX_ENTRIES then
                omitted = omitted + 1
            else
                count = count + 1
                local key = k
                if typeof(k) ~= "string" and typeof(k) ~= "number" then
                    key = tostring(k)
                end
                result[key] = RYS.Sanitize(v, depth + 1, seen)
            end
        end
        if omitted > 0 then
            result["__omitted"] = omitted .. " entries omitted"
        end
        
        seen[value] = nil
        return result
    end
    
    -- DeepInspect: สร้างข้อความอ่านง่ายจาก table ที่ sanitize แล้ว
    function RYS.DeepInspect(value, indent)
        indent = indent or 0
        local sanitized = RYS.Sanitize(value)
        local lines = {}
        local prefix = string.rep("  ", indent)
        
        if type(sanitized) ~= "table" then
            return prefix .. tostring(sanitized)
        end
        
        for k, v in pairs(sanitized) do
            if type(v) == "table" then
                table.insert(lines, prefix .. tostring(k) .. ":")
                table.insert(lines, RYS.DeepInspect(v, indent + 1))
            else
                table.insert(lines, prefix .. tostring(k) .. " = " .. tostring(v))
            end
        end
        
        return table.concat(lines, "\n")
    end
end

return RYS
