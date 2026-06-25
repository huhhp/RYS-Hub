--[[
    RYS Hub — Connection Manager
    จัดการ Connection ทั้งหมด ป้องกัน Memory Leak
    มี Throttle system ลดภาระ CPU
--]]

local ConnMgr = {}
ConnMgr._pools = {}     -- { [moduleName] = { conn1, conn2, ... } }
ConnMgr._throttles = {} -- { [id] = { lastRun = 0, interval = n } }
ConnMgr._idCounter = 0

-- ═══════════════════════════════════════
-- CONNECTION POOL
-- ═══════════════════════════════════════

--- เพิ่ม connection เข้ากลุ่มของ module
function ConnMgr:Add(moduleName, connection)
    if not self._pools[moduleName] then
        self._pools[moduleName] = {}
    end
    table.insert(self._pools[moduleName], connection)
    return connection
end

--- Disconnect ทั้งหมดในกลุ่ม module
function ConnMgr:DisconnectAll(moduleName)
    local pool = self._pools[moduleName]
    if not pool then return end
    for i = #pool, 1, -1 do
        local conn = pool[i]
        if conn and typeof(conn) == "RBXScriptConnection" then
            pcall(function() conn:Disconnect() end)
        end
        pool[i] = nil
    end
    self._pools[moduleName] = nil
end

--- Disconnect ทุก module ทั้งหมด (cleanup)
function ConnMgr:DisconnectEverything()
    for moduleName, _ in pairs(self._pools) do
        self:DisconnectAll(moduleName)
    end
    self._pools = {}
    self._throttles = {}
end

--- นับ connection ที่ active อยู่
function ConnMgr:GetCount(moduleName)
    if moduleName then
        return self._pools[moduleName] and #self._pools[moduleName] or 0
    end
    local total = 0
    for _, pool in pairs(self._pools) do
        total = total + #pool
    end
    return total
end

-- ═══════════════════════════════════════
-- THROTTLE SYSTEM
-- ═══════════════════════════════════════
-- ลดจำนวนครั้งที่ callback ทำงาน
-- แทนที่จะทำงานทุกเฟรม (60 ครั้ง/วินาที)
-- ทำงานตาม interval ที่กำหนด

--- สร้าง throttled callback
--- @param interval number — วินาทีขั้นต่ำระหว่างแต่ละครั้ง
--- @param callback function — ฟังก์ชันที่จะถูกเรียก
--- @return function — throttled version ของ callback
function ConnMgr:CreateThrottle(interval, callback)
    self._idCounter = self._idCounter + 1
    local id = self._idCounter
    self._throttles[id] = {
        lastRun = 0,
        interval = interval,
    }
    
    return function(dt)
        local data = self._throttles[id]
        if not data then return end
        data.lastRun = data.lastRun + (dt or 0)
        if data.lastRun >= data.interval then
            data.lastRun = 0
            callback(dt)
        end
    end
end

--- สร้าง throttled RenderStepped connection พร้อม auto-add เข้า pool
--- @param moduleName string — ชื่อ module
--- @param interval number — throttle interval (วินาที)
--- @param callback function — ฟังก์ชันที่จะทำงาน
--- @param eventType string? — "RenderStepped" | "Heartbeat" | "Stepped" (default: Heartbeat)
function ConnMgr:AddThrottled(moduleName, interval, callback, eventType)
    local RunService = game:GetService("RunService")
    local event
    
    if eventType == "RenderStepped" then
        event = RunService.RenderStepped
    elseif eventType == "Stepped" then
        event = RunService.Stepped
    else
        event = RunService.Heartbeat  -- default: Heartbeat (ดีกว่า RenderStepped สำหรับ logic)
    end
    
    local throttledFn = self:CreateThrottle(interval, callback)
    local conn = event:Connect(throttledFn)
    self:Add(moduleName, conn)
    return conn
end

--- สร้าง connection ธรรมดา (ไม่ throttle) พร้อม auto-add เข้า pool
function ConnMgr:AddConnection(moduleName, event, callback)
    local conn = event:Connect(callback)
    self:Add(moduleName, conn)
    return conn
end

-- ═══════════════════════════════════════
-- DEBUG
-- ═══════════════════════════════════════
function ConnMgr:PrintStats()
    print("━━━━━━━━ RYS CONNECTION STATS ━━━━━━━━")
    print("Total pools: " .. self:GetCount())
    for name, pool in pairs(self._pools) do
        print(string.format("  [%s] %d connections", name, #pool))
    end
    print("Throttle entries: " .. self._idCounter)
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
end

return ConnMgr
