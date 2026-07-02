--[[
    RYS Hub — Bridge Module v5.0
    🌐 EXTERNAL COMMAND BRIDGE (Inspired by roblox-executor-mcp)
    
    สถาปัตยกรรม:
    ┌─────────────────┐     WebSocket/HTTP      ┌──────────────┐
    │  Roblox Client  │ ◄──────────────────────► │  RYS Bridge  │
    │  (RYS-Hub Lua)  │     localhost:16400      │  (External)  │
    └─────────────────┘                          └──────────────┘
    
    ฟีเจอร์:
    1. WebSocket Bridge (real-time, bidirectional)
    2. HTTP Polling Bridge (fallback สำหรับ executor ที่ไม่มี WebSocket)
    3. Exponential Backoff Reconnection
    4. Type-based Command Routing (callback system)
    5. Output Sanitization ก่อนส่งกลับ
    6. Heartbeat / Keep-Alive
    
    ⚡ รองรับการรับคำสั่งจากภายนอก เช่น AI Agent, Dashboard, หรือ Remote Tool
    ⚠️ ทำงานบน localhost เท่านั้น — ไม่เปิดพอร์ตให้ภายนอก
--]]

return function(RYS, ConnMgr)
    local Bridge = {}
    local MODULE_NAME = "Bridge"
    
    local HttpService = game:GetService("HttpService")
    local Players = game:GetService("Players")
    local MarketplaceService = game:GetService("MarketplaceService")
    local LocalPlayer = Players.LocalPlayer
    
    -- ═══════════════════════════════════════
    -- CONFIG
    -- ═══════════════════════════════════════
    Bridge.Config = {
        URL = "localhost:16400",          -- Bridge URL (เปลี่ยนได้)
        Mode = "auto",                    -- "websocket" | "http" | "auto"
        HeartbeatInterval = 10,           -- วินาที
        MaxReconnectAttempts = 10,
        MaxRetryDelay = 5,                -- วินาที
        PollInterval = 0.5,              -- HTTP polling interval (วินาที)
    }
    
    -- State
    Bridge.Connected = false
    Bridge.Mode = "none"                  -- "websocket" | "http"
    Bridge.ClientId = nil
    Bridge.Callbacks = {}
    Bridge.RawCallbacks = {}
    Bridge.CommandLog = {}
    Bridge.Stats = {
        CommandsReceived = 0,
        CommandsExecuted = 0,
        Errors = 0,
        Reconnects = 0,
    }
    
    -- Internal refs
    local wsConnection = nil
    local isShuttingDown = false
    
    -- ═══════════════════════════════════════
    -- SANITIZATION (จาก connector.luau)
    -- ═══════════════════════════════════════
    local SANITIZE_MAX_DEPTH = 8
    local SANITIZE_MAX_ENTRIES = 60
    local SANITIZE_MAX_STRING = 500
    
    local function SanitizeForOutput(value, depth, seen)
        depth = depth or 0
        local valueType = typeof(value)
        
        if valueType == "Instance" then
            local ok, full = pcall(function() return value:GetFullName() end)
            return ok and full or tostring(value)
        elseif valueType == "string" then
            if #value > SANITIZE_MAX_STRING then
                return string.sub(value, 1, SANITIZE_MAX_STRING)
                    .. "…(+" .. (#value - SANITIZE_MAX_STRING) .. " chars omitted)"
            end
            return value
        elseif valueType == "number" or valueType == "boolean" or valueType == "nil" then
            return value
        elseif valueType ~= "table" then
            return tostring(value)
        end
        
        if depth >= SANITIZE_MAX_DEPTH then
            return "<table: max depth reached>"
        end
        
        seen = seen or {}
        if seen[value] then
            return "<cyclic table>"
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
                result[key] = SanitizeForOutput(v, depth + 1, seen)
            end
        end
        if omitted > 0 then
            result["__omitted"] = omitted .. " more entries omitted"
        end
        
        seen[value] = nil
        return result
    end
    
    -- ═══════════════════════════════════════
    -- REGISTRATION INFO
    -- ═══════════════════════════════════════
    local function GetRegistrationInfo()
        local placeName = "Unknown"
        pcall(function()
            local info = MarketplaceService:GetProductInfo(game.PlaceId)
            placeName = info.Name
        end)
        
        return {
            type = "register",
            source = "RYS-Hub",
            version = RYS.Version,
            executor = RYS.Executor,
            username = LocalPlayer and LocalPlayer.Name or "Unknown",
            userId = LocalPlayer and LocalPlayer.UserId or 0,
            placeId = game.PlaceId,
            jobId = game.JobId,
            placeName = placeName,
        }
    end
    
    -- ═══════════════════════════════════════
    -- RESPONSE FORMATTER
    -- ═══════════════════════════════════════
    local function FormatResponse(message, id, isError)
        if isError then
            return HttpService:JSONEncode({
                error = tostring(message),
                success = false,
                id = id
            })
        end
        
        local output = SanitizeForOutput(message)
        if typeof(output) ~= "table" then
            output = { output }
        end
        
        return HttpService:JSONEncode({
            output = output,
            success = true,
            id = id
        })
    end
    
    -- ═══════════════════════════════════════
    -- COMMAND HANDLER
    -- ═══════════════════════════════════════
    local function HandleMessage(jsonStr)
        local ok, data = pcall(function()
            return HttpService:JSONDecode(jsonStr)
        end)
        
        if not ok or not data or not data.type then
            return FormatResponse("Invalid JSON or missing 'type'", nil, true)
        end
        
        Bridge.Stats.CommandsReceived = Bridge.Stats.CommandsReceived + 1
        
        -- Log command
        table.insert(Bridge.CommandLog, {
            Type = data.type,
            Time = os.clock(),
            Id = data.id
        })
        -- Keep log at max 100 entries
        if #Bridge.CommandLog > 100 then
            table.remove(Bridge.CommandLog, 1)
        end
        
        local callback = Bridge.Callbacks[data.type]
        if not callback then
            return FormatResponse("Unknown command type: " .. tostring(data.type), data.id, true)
        end
        
        local success, result = pcall(function()
            return callback(data)
        end)
        
        if not success then
            Bridge.Stats.Errors = Bridge.Stats.Errors + 1
            return FormatResponse(result, data.id, true)
        end
        
        Bridge.Stats.CommandsExecuted = Bridge.Stats.CommandsExecuted + 1
        
        if Bridge.RawCallbacks[data.type] then
            return HttpService:JSONEncode({
                output = tostring(result),
                success = true,
                id = data.id
            })
        end
        
        return FormatResponse(result, data.id, false)
    end
    
    -- ═══════════════════════════════════════
    -- BIND COMMANDS
    -- ═══════════════════════════════════════
    function Bridge.BindCommand(commandType, callback)
        Bridge.Callbacks[commandType] = callback
    end
    
    function Bridge.BindCommandRaw(commandType, callback)
        Bridge.Callbacks[commandType] = callback
        Bridge.RawCallbacks[commandType] = true
    end
    
    -- ═══════════════════════════════════════
    -- BUILT-IN COMMANDS
    -- ═══════════════════════════════════════
    local function RegisterBuiltinCommands()
        -- Execute arbitrary Lua code
        Bridge.BindCommandRaw("execute", function(data)
            if not data.code then
                error("Missing 'code' parameter")
            end
            local func, compileErr = loadstring(data.code)
            if not func then
                error("Compile error: " .. tostring(compileErr))
            end
            local ok, result = pcall(func)
            if not ok then
                error("Runtime error: " .. tostring(result))
            end
            return tostring(result or "OK")
        end)
        
        -- Toggle a RYS module
        Bridge.BindCommand("toggle", function(data)
            local moduleName = data.module
            local state = data.state
            if not moduleName then error("Missing 'module' parameter") end
            
            local mod = RYS.Modules[moduleName]
            if not mod then error("Module not found: " .. moduleName) end
            if not mod.Toggle then error("Module has no Toggle function: " .. moduleName) end
            
            mod.Toggle(state ~= false)
            return { module = moduleName, enabled = state ~= false }
        end)
        
        -- Get RYS state
        Bridge.BindCommand("status", function(_)
            return {
                version = RYS.Version,
                executor = RYS.Executor,
                enabled = RYS.Enabled,
                modules = {},
                bridge = Bridge.Stats,
            }
        end)
        
        -- List loaded modules
        Bridge.BindCommand("modules", function(_)
            local list = {}
            for name, _ in pairs(RYS._loaded) do
                table.insert(list, name)
            end
            return list
        end)
        
        -- Ping
        Bridge.BindCommand("ping", function(_)
            return {
                pong = true,
                time = os.clock(),
                ping = LocalPlayer:GetNetworkPing()
            }
        end)
        
        -- Get player info
        Bridge.BindCommand("player-info", function(_)
            return GetRegistrationInfo()
        end)
        
        -- Get settings
        Bridge.BindCommand("settings", function(data)
            if data.set then
                for k, v in pairs(data.set) do
                    if RYS.Settings[k] ~= nil then
                        RYS.Settings[k] = v
                    end
                end
            end
            return RYS.Settings
        end)
    end
    
    -- ═══════════════════════════════════════
    -- SERVER ALIVE CHECK
    -- ═══════════════════════════════════════
    local function IsServerAlive()
        local success, result = pcall(function()
            local response = nil
            local thread = task.spawn(function()
                local ok, data = pcall(request, {
                    Url = "http://" .. Bridge.Config.URL,
                    Method = "GET"
                })
                if ok then response = data end
            end)
            
            local start = os.clock()
            repeat task.wait(0.05) until response ~= nil or os.clock() - start > 3
            
            if response == nil then
                pcall(task.cancel, thread)
                return false
            end
            
            return response.StatusCode == 200 or response.StatusCode == 426
        end)
        
        return success and result
    end
    
    -- ═══════════════════════════════════════
    -- WEBSOCKET BRIDGE
    -- ═══════════════════════════════════════
    local function ConnectWebSocket()
        local hasWebSocket = typeof(WebSocket) ~= "nil" and typeof(WebSocket.connect) == "function"
        if not hasWebSocket then return false end
        
        -- Exponential backoff retry
        local retryDelay = 0.5
        local attempts = 0
        
        while not IsServerAlive() do
            attempts = attempts + 1
            if attempts >= Bridge.Config.MaxReconnectAttempts then
                warn("[RYS Bridge] ❌ Server ไม่ตอบหลัง " .. attempts .. " ครั้ง")
                return false
            end
            task.wait(retryDelay)
            retryDelay = math.min(retryDelay * 1.5, Bridge.Config.MaxRetryDelay)
        end
        
        -- Connect
        local connResult = nil
        local connThread = task.spawn(function()
            local ok, ws = pcall(function()
                return WebSocket.connect("ws://" .. Bridge.Config.URL)
            end)
            if ok then connResult = ws end
        end)
        
        local connStart = os.clock()
        repeat task.wait(0.05) until connResult ~= nil or os.clock() - connStart > 5
        
        if connResult == nil then
            pcall(task.cancel, connThread)
            return false
        end
        
        wsConnection = connResult
        Bridge.Connected = true
        Bridge.Mode = "websocket"
        
        -- Send registration
        pcall(function()
            wsConnection:Send(HttpService:JSONEncode(GetRegistrationInfo()))
        end)
        
        -- Message handler
        wsConnection.OnMessage:Connect(function(message)
            local response = HandleMessage(message)
            if response then
                pcall(function()
                    wsConnection:Send(response)
                end)
            end
        end)
        
        -- Close handler
        wsConnection.OnClose:Connect(function()
            Bridge.Connected = false
            wsConnection = nil
            
            if not isShuttingDown then
                Bridge.Stats.Reconnects = Bridge.Stats.Reconnects + 1
                warn("[RYS Bridge] ⚠️ WebSocket ถูกตัด — พยายามต่อใหม่...")
                task.delay(2, function()
                    if not isShuttingDown then
                        ConnectWebSocket()
                    end
                end)
            end
        end)
        
        return true
    end
    
    -- ═══════════════════════════════════════
    -- HTTP POLLING BRIDGE (FALLBACK)
    -- ═══════════════════════════════════════
    local httpPolling = false
    
    local function StartHttpPolling()
        if httpPolling then return end
        httpPolling = true
        Bridge.Mode = "http"
        Bridge.Connected = true
        
        -- Register
        pcall(function()
            local resp = request({
                Url = "http://" .. Bridge.Config.URL .. "/register",
                Method = "POST",
                Body = HttpService:JSONEncode(GetRegistrationInfo()),
                Headers = { ["Content-Type"] = "application/json" }
            })
            if resp.StatusCode == 200 then
                local data = HttpService:JSONDecode(resp.Body)
                Bridge.ClientId = data.clientId
            end
        end)
        
        -- Polling loop
        ConnMgr:AddThrottled(MODULE_NAME .. "_poll", Bridge.Config.PollInterval, function()
            if not Bridge.Connected or isShuttingDown then return end
            
            local ok, resp = pcall(request, {
                Url = "http://" .. Bridge.Config.URL .. "/poll"
                    .. (Bridge.ClientId and ("?clientId=" .. Bridge.ClientId) or ""),
                Method = "GET"
            })
            
            if ok and resp and resp.StatusCode == 200 and resp.Body ~= "" then
                local response = HandleMessage(resp.Body)
                if response then
                    pcall(request, {
                        Url = "http://" .. Bridge.Config.URL .. "/respond",
                        Method = "POST",
                        Body = response,
                        Headers = { ["Content-Type"] = "application/json" }
                    })
                end
            end
        end)
        
        -- Heartbeat
        ConnMgr:AddThrottled(MODULE_NAME .. "_heartbeat", Bridge.Config.HeartbeatInterval, function()
            if not Bridge.Connected or isShuttingDown then return end
            pcall(request, {
                Url = "http://" .. Bridge.Config.URL .. "/heartbeat"
                    .. (Bridge.ClientId and ("?clientId=" .. Bridge.ClientId) or ""),
                Method = "POST"
            })
        end)
    end
    
    -- ═══════════════════════════════════════
    -- SEND MESSAGE (outbound)
    -- ═══════════════════════════════════════
    function Bridge.Send(data)
        if not Bridge.Connected then return false end
        
        local jsonStr = HttpService:JSONEncode(data)
        
        if Bridge.Mode == "websocket" and wsConnection then
            local ok = pcall(function()
                wsConnection:Send(jsonStr)
            end)
            return ok
        elseif Bridge.Mode == "http" then
            local ok = pcall(request, {
                Url = "http://" .. Bridge.Config.URL .. "/message",
                Method = "POST",
                Body = jsonStr,
                Headers = { ["Content-Type"] = "application/json" }
            })
            return ok
        end
        
        return false
    end
    
    -- ═══════════════════════════════════════
    -- TOGGLE
    -- ═══════════════════════════════════════
    function Bridge.Toggle(state)
        RYS.Enabled.Bridge = state
        
        if state then
            isShuttingDown = false
            RegisterBuiltinCommands()
            
            local connected = false
            
            if Bridge.Config.Mode == "auto" or Bridge.Config.Mode == "websocket" then
                connected = ConnectWebSocket()
            end
            
            if not connected and (Bridge.Config.Mode == "auto" or Bridge.Config.Mode == "http") then
                if IsServerAlive() then
                    StartHttpPolling()
                    connected = true
                end
            end
            
            if connected then
                RYS.Notify("Bridge", "🌐 เชื่อมต่อแล้ว! (Mode: " .. Bridge.Mode .. ")\nURL: " .. Bridge.Config.URL)
            else
                RYS.Notify("Bridge", "⚠️ ไม่พบ Bridge Server\nรอการเชื่อมต่อที่ " .. Bridge.Config.URL)
                -- Passive mode: ลงทะเบียน commands ไว้ แต่ยังไม่เชื่อมต่อ
                Bridge.Connected = false
                Bridge.Mode = "standby"
            end
        else
            isShuttingDown = true
            Bridge.Connected = false
            
            if wsConnection then
                pcall(function() wsConnection:Close() end)
                wsConnection = nil
            end
            
            httpPolling = false
            ConnMgr:DisconnectAll(MODULE_NAME .. "_poll")
            ConnMgr:DisconnectAll(MODULE_NAME .. "_heartbeat")
            
            Bridge.Mode = "none"
            RYS.Notify("Bridge", "❌ ปิดการเชื่อมต่อแล้ว\nStats: " .. Bridge.Stats.CommandsExecuted .. " commands executed")
        end
    end
    
    -- ═══════════════════════════════════════
    -- PUBLIC API
    -- ═══════════════════════════════════════
    function Bridge.GetStats()
        return Bridge.Stats
    end
    
    function Bridge.GetLog()
        return Bridge.CommandLog
    end
    
    function Bridge.SetURL(url)
        Bridge.Config.URL = url
    end
    
    -- Export Sanitize สำหรับ modules อื่นใช้
    Bridge.SanitizeForOutput = SanitizeForOutput
    
    RYS.RegisterModule("Bridge", Bridge)
    return Bridge
end
