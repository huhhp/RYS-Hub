--[[
    RYS Hub — Core Init
    State Management + Config + Utilities
    ทุก Module ใช้ร่วมกัน
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
    Version = "4.0",
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
    },
    Settings = {
        AimbotFOV = 250,
        AimbotSmoothing = 0.15,
        AimbotTargetPart = "Head",
        FlySpeed = 80,
        WalkSpeed = 50,
        JumpPower = 120,
        ESPColor = Color3.fromRGB(0, 255, 200),
        ESPEnemyColor = Color3.fromRGB(255, 50, 50),
        ESPTeamColor = Color3.fromRGB(50, 255, 50),
        HitboxSize = 15,
        NoclipSpeed = 1,
        TeleportKey = Enum.KeyCode.T,
        FreecamSpeed = 2,
        KillAuraRange = 25,
    },
    GUI = nil,
    Modules = {},    -- เก็บ reference ของ module ที่โหลดแล้ว
    _loaded = {},    -- track ว่าโหลด module ไหนแล้ว
}

-- ═══════════════════════════════════════
-- SERVICES (ส่งออกให้ module อื่นใช้)
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
-- UTILITY FUNCTIONS
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
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "⚡ RYS | " .. title,
            Text = text,
            Duration = duration or 3,
        })
    end)
end

-- ═══════════════════════════════════════
-- MODULE LOADER HELPER
-- ═══════════════════════════════════════
function RYS.RegisterModule(name, module)
    RYS.Modules[name] = module
    RYS._loaded[name] = true
end

function RYS.IsModuleLoaded(name)
    return RYS._loaded[name] == true
end

return RYS
