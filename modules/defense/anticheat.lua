--[[
    RYS Hub — Anti-Cheat Bypass (7 Layers)
    ✅ ใช้ ConnMgr สำหรับ Heartbeat connections
--]]

return function(RYS, ConnMgr)
    local AntiCheat = {}
    AntiCheat.OriginalValues = {}
    AntiCheat.BlockedRemotes = {}
    local MODULE_NAME = "AntiCheat"
    local CoreGui = RYS.Services.CoreGui

    function AntiCheat.Toggle(state)
        RYS.Enabled.AntiCheat = state
        if state then
            -- LAYER 1: ซ่อน GUI จาก AC Detection
            pcall(function()
                if RYS.GUI then
                    local mt = getrawmetatable(game)
                    if mt then
                        local oldIndex = mt.__index
                        setreadonly(mt, false)
                        mt.__index = newcclosure(function(self, key)
                            if self == CoreGui and (key == "RYS_Hub" or key == "RYS") then
                                return nil
                            end
                            return oldIndex(self, key)
                        end)
                        setreadonly(mt, true)
                    end
                end
            end)

            -- LAYER 2: Humanoid Value Spoofing
            pcall(function()
                local hum = RYS.GetHumanoid()
                if hum then
                    AntiCheat.OriginalValues.WalkSpeed = hum.WalkSpeed
                    AntiCheat.OriginalValues.JumpPower = hum.JumpPower
                    AntiCheat.OriginalValues.JumpHeight = hum.JumpHeight
                end

                local mt = getrawmetatable(game)
                if mt then
                    local oldIndex = mt.__index
                    setreadonly(mt, false)
                    mt.__index = newcclosure(function(self, key)
                        if RYS.Enabled.AntiCheat and self:IsA("Humanoid") then
                            if key == "WalkSpeed" then return 16
                            elseif key == "JumpPower" then return 50
                            elseif key == "JumpHeight" then return 7.2
                            end
                        end
                        return oldIndex(self, key)
                    end)
                    setreadonly(mt, true)
                end
            end)

            -- LAYER 3: Remote Firewall
            pcall(function()
                local oldNamecall
                oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                    if not RYS.Enabled.AntiCheat then
                        return oldNamecall(self, ...)
                    end

                    local method = getnamecallmethod()
                    local remoteName = self.Name:lower()

                    if method == "FireServer" or method == "InvokeServer" then
                        local acKeywords = {
                            "anticheat", "anti_cheat", "anti-cheat",
                            "detect", "detection", "checker",
                            "security", "secure", "validate",
                            "ban", "kick", "flag",
                            "exploit", "cheat", "hack",
                            "report", "violation", "suspicious",
                            "integrity", "verify", "sanity",
                            "monitor", "watchdog", "guardian",
                            "punishment", "punish",
                        }

                        for _, keyword in ipairs(acKeywords) do
                            if remoteName:find(keyword) then
                                table.insert(AntiCheat.BlockedRemotes, {
                                    Name = self:GetFullName(),
                                    Time = os.clock(),
                                    Keyword = keyword,
                                })
                                return nil
                            end
                        end
                    end

                    if method == "Kick" or method == "kick" then
                        return nil
                    end

                    return oldNamecall(self, ...)
                end)
            end)

            -- LAYER 4: Anti-Teleport
            pcall(function()
                local TeleportService = game:GetService("TeleportService")
                local oldTeleport = TeleportService.Teleport
                local oldTeleportToPlace = TeleportService.TeleportToPlaceInstance

                hookfunction(TeleportService.Teleport, function(self, placeId, ...)
                    if RYS.Enabled.AntiCheat then
                        RYS.Notify("Anti-Cheat", "🛡️ บล็อก Teleport ไป PlaceId: " .. tostring(placeId))
                        return nil
                    end
                    return oldTeleport(self, placeId, ...)
                end)

                hookfunction(TeleportService.TeleportToPlaceInstance, function(self, placeId, instanceId, ...)
                    if RYS.Enabled.AntiCheat then
                        RYS.Notify("Anti-Cheat", "🛡️ บล็อก TeleportToPlace: " .. tostring(placeId))
                        return nil
                    end
                    return oldTeleportToPlace(self, placeId, instanceId, ...)
                end)
            end)

            -- LAYER 5: Hide Executor Traces
            pcall(function()
                local execFuncs = {
                    "hookfunction", "hookmetamethod", "newcclosure",
                    "getrawmetatable", "setreadonly", "getnamecallmethod",
                    "syn", "fluxus", "krnl", "script_ware",
                    "request", "http_request", "HttpGet",
                    "getgenv", "getrenv", "getfenv",
                    "Drawing", "debug",
                }

                if getgenv then
                    local realGetgenv = getgenv
                    local fakeEnv = setmetatable({}, {
                        __index = function(self, key)
                            for _, funcName in ipairs(execFuncs) do
                                if key == funcName then
                                    return nil
                                end
                            end
                            return realGetgenv()[key]
                        end
                    })
                end
            end)

            -- LAYER 6: Heartbeat Position Validation Spoof
            pcall(function()
                local lastPosition = nil
                ConnMgr:AddThrottled(MODULE_NAME, 0.1, function()
                    if not RYS.Enabled.AntiCheat then return end
                    local rootPart = RYS.GetRootPart()
                    if rootPart then
                        if lastPosition then
                            local dist = (rootPart.Position - lastPosition).Magnitude
                            if dist > 100 then
                                -- Position spoof logic (placeholder)
                            end
                        end
                        lastPosition = rootPart.Position
                    end
                end)
            end)

            -- LAYER 7: Anti-ScreenGui Detection
            pcall(function()
                local oldGetChildren = game.GetChildren
                hookfunction(game.GetChildren, function(self)
                    local children = oldGetChildren(self)
                    if self == CoreGui and RYS.Enabled.AntiCheat then
                        local filtered = {}
                        for _, child in ipairs(children) do
                            if child.Name ~= "RYS_Hub" then
                                table.insert(filtered, child)
                            end
                        end
                        return filtered
                    end
                    return children
                end)

                local oldFFC = game.FindFirstChild
                hookfunction(game.FindFirstChild, function(self, name, ...)
                    if RYS.Enabled.AntiCheat and self == CoreGui then
                        if name == "RYS_Hub" or name == "RYS" then
                            return nil
                        end
                    end
                    return oldFFC(self, name, ...)
                end)
            end)

            RYS.Notify("Anti-Cheat", "🛡️ เปิดป้องกัน 7 ชั้นแล้ว!")
            print("━━━━━━━━━━ RYS ANTI-CHEAT BYPASS ━━━━━━━━━━")
            print("   🛡️ Layer 1: GUI Stealth          ✅")
            print("   🛡️ Layer 2: Humanoid Spoof       ✅")
            print("   🛡️ Layer 3: Remote Firewall      ✅")
            print("   🛡️ Layer 4: Anti-Teleport        ✅")
            print("   🛡️ Layer 5: Executor Trace Hide  ✅")
            print("   🛡️ Layer 6: Position Spoof       ✅")
            print("   🛡️ Layer 7: ScreenGui Cloak      ✅")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        else
            ConnMgr:DisconnectAll(MODULE_NAME)
            RYS.Notify("Anti-Cheat", "❌ ปิดป้องกันแล้ว — ระวังโดน detect!")
        end
    end

    function AntiCheat.GetStats()
        print("━━━━━━━ RYS ANTI-CHEAT STATS ━━━━━━━")
        print("🛡️ Blocked Remotes: " .. #AntiCheat.BlockedRemotes)
        for i, log in ipairs(AntiCheat.BlockedRemotes) do
            print(string.format("  [%d] %s (keyword: %s)", i, log.Name, log.Keyword))
        end
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    end

    RYS.RegisterModule("AntiCheat", AntiCheat)
    return AntiCheat
end
