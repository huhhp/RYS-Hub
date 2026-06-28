--[[
    RYS Hub — Kill Aura Module (UPGRADED: INSTANT CRITICAL TOUCH + BACKSTAB TELEPORT + FAST ATTACK)
    ✅ Instant Touches (Fire touch events at high frequency)
    ✅ Backstab Teleport (Instantly positions behind the target)
    ✅ Auto weapon selector (Automatically equips tools from backpack/character)
--]]

return function(RYS, ConnMgr)
    local KillAura = {}
    local Players = RYS.Services.Players
    local LocalPlayer = RYS.Services.LocalPlayer
    local MODULE_NAME = "KillAura"

    local function EquipBestTool()
        local char = RYS.GetCharacter()
        if not char then return end
        
        -- Check if already holding a tool
        local currentTool = char:FindFirstChildOfClass("Tool")
        if currentTool then return currentTool end

        -- Equip from backpack
        local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
        if backpack then
            local tool = backpack:FindFirstChildOfClass("Tool")
            if tool then
                tool.Parent = char
                return tool
            end
        end
        return nil
    end

    function KillAura.Toggle(state)
        RYS.Enabled.KillAura = state
        if state then
            -- Increased tickrate (0.02s / 50hz) for near instant attack
            ConnMgr:AddThrottled(MODULE_NAME, 0.02, function()
                if not RYS.Enabled.KillAura then return end
                local myRoot = RYS.GetRootPart()
                if not myRoot then return end

                local target, targetDist = RYS.GetClosestEnemy()
                if target and target.Character then
                    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
                    if targetRoot and targetDist <= RYS.Settings.KillAuraRange then
                        
                        -- Equip weapon automatically
                        local tool = EquipBestTool()
                        if tool then
                            tool:Activate()
                        end

                        -- Backstab Teleport option (positions 2.5 studs behind the target face direction)
                        pcall(function()
                            if RYS.Settings.RageMode then
                                myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 2.5)
                            end
                        end)

                        -- Multi-touch interest hit registers
                        pcall(function()
                            if firetouchinterest then
                                -- Fire multiple touches to bypass delay & register critical hit
                                for i = 1, 3 do
                                    firetouchinterest(myRoot, targetRoot, 0)
                                    task.wait()
                                    firetouchinterest(myRoot, targetRoot, 1)
                                end
                            end
                        end)
                    end
                end
            end)
            RYS.Notify("Kill Aura", "⚡ GOD Kill Aura Active (Auto-Equip & Rapid Touch Enabled!)")
        else
            ConnMgr:DisconnectAll(MODULE_NAME)
            RYS.Notify("Kill Aura", "❌ Disabled")
        end
    end

    RYS.RegisterModule("KillAura", KillAura)
    return KillAura
end
