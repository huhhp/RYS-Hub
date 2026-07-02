--[[
    RYS Hub — Anti-Kick Module v5.0 (UPGRADED)
    🚫 MULTI-LAYER KICK PREVENTION
    
    Layer 1: __namecall Hook — สกัด Player:Kick() method
    Layer 2: Remote Event Block — บล็อก RemoteEvent ที่ชื่อ kick/ban/remove
    Layer 3: hookfunction — Hook ฟังก์ชัน Kick ตรงๆ
    Layer 4: Connection Intercept — สกัด BindableEvent ที่ trigger kick
--]]

return function(RYS, ConnMgr)
    local AntiKick = {}
    local MODULE_NAME = "AntiKick"
    local LocalPlayer = RYS.Services.LocalPlayer
    
    AntiKick.BlockedAttempts = 0
    AntiKick.BlockLog = {}
    
    function AntiKick.Toggle(state)
        RYS.Enabled.AntiKick = state
        if state then
            -- Layer 1: __namecall Hook (สกัด :Kick())
            pcall(function()
                if hookmetamethod then
                    local oldNamecall
                    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
                        local method = getnamecallmethod()
                        if RYS.Enabled.AntiKick then
                            -- บล็อค Kick methods ทั้งหมด
                            if method == "Kick" or method == "kick" then
                                AntiKick.BlockedAttempts = AntiKick.BlockedAttempts + 1
                                table.insert(AntiKick.BlockLog, {
                                    Method = "Namecall:Kick",
                                    Time = os.clock(),
                                    Args = {...}
                                })
                                warn("[RYS] 🚫 Kick attempt BLOCKED! (#" .. AntiKick.BlockedAttempts .. ")")
                                return nil
                            end
                            -- บล็อค Disconnect methods
                            if method == "Disconnect" and self == LocalPlayer then
                                AntiKick.BlockedAttempts = AntiKick.BlockedAttempts + 1
                                return nil
                            end
                        end
                        return oldNamecall(self, ...)
                    end))
                end
            end)
            
            -- Layer 2: Remote Event Firewall (บล็อค remotes ที่เกี่ยวกับ kick)
            local KICK_KEYWORDS = {"kick", "ban", "remove", "punish", "disconnect", "leave"}
            
            pcall(function()
                if hookmetamethod then
                    local oldIndex
                    oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
                        if RYS.Enabled.AntiKick then
                            local keyLower = tostring(key):lower()
                            for _, word in ipairs(KICK_KEYWORDS) do
                                if keyLower:find(word) then
                                    if self:IsA("RemoteEvent") or self:IsA("RemoteFunction") then
                                        AntiKick.BlockedAttempts = AntiKick.BlockedAttempts + 1
                                        warn("[RYS] 🚫 Blocked kick remote access: " .. tostring(key))
                                        return nil
                                    end
                                end
                            end
                        end
                        return oldIndex(self, key)
                    end))
                end
            end)
            
            -- Layer 3: hookfunction (Hook Kick ตรงๆ)
            pcall(function()
                if hookfunction then
                    local origKick = LocalPlayer.Kick
                    hookfunction(LocalPlayer.Kick, newcclosure(function(self, ...)
                        if RYS.Enabled.AntiKick then
                            AntiKick.BlockedAttempts = AntiKick.BlockedAttempts + 1
                            warn("[RYS] 🚫 Direct Kick function BLOCKED!")
                            return nil
                        end
                        return origKick(self, ...)
                    end))
                end
            end)
            
            -- Layer 4: Monitor for teleport-to-ban-place attempts
            pcall(function()
                local TPS = game:GetService("TeleportService")
                if hookfunction then
                    local origTP = TPS.Teleport
                    hookfunction(TPS.Teleport, newcclosure(function(self, placeId, ...)
                        -- บล็อคถ้าพยายาม teleport ไป ban/kick place
                        if RYS.Enabled.AntiKick and placeId ~= game.PlaceId then
                            -- ตรวจว่า teleport นี้ถูกเรียกจาก server หรือไม่
                            local info = debug.info(2, "s")
                            if info and (info:find("kick") or info:find("ban") or info:find("punishment")) then
                                AntiKick.BlockedAttempts = AntiKick.BlockedAttempts + 1
                                warn("[RYS] 🚫 Ban teleport BLOCKED! PlaceId: " .. tostring(placeId))
                                return nil
                            end
                        end
                        return origTP(self, placeId, ...)
                    end))
                end
            end)
            
            RYS.Notify("Anti-Kick", "🚫 4-Layer Kick Shield เปิดแล้ว!\nNamecall + Remote + Direct + Teleport Protection")
        else
            RYS.Notify("Anti-Kick", "❌ ปิดแล้ว — บล็อค " .. AntiKick.BlockedAttempts .. " ครั้ง")
        end
    end
    
    function AntiKick.GetStats()
        return {
            Blocked = AntiKick.BlockedAttempts,
            Log = AntiKick.BlockLog
        }
    end
    
    RYS.RegisterModule("AntiKick", AntiKick)
    return AntiKick
end
