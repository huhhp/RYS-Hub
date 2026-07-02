--[[
    RYS Hub — Mini Script Console v5.0
    
    Features:
    1. UI สำหรับพิมพ์ Lua Code ลงไป
    2. รัน (Execute) ภายในสคริปต์ตัวเองเพื่อทำงานสั้นๆ
    3. ดักจับข้อผิดพลาด (pcall) และแสดงผลในช่อง Output
--]]

return function(RYS, ConnMgr)
    local Console = {}
    
    -- Function สำหรับให้ GUI เอาไปผูก
    function Console.ExecuteCode(codeString)
        if type(codeString) ~= "string" or codeString == "" then
            return false, "กรุณาใส่โค้ดที่ต้องการรัน"
        end
        
        -- ใช้ loadstring ที่มีใน Executor (หรือพยายามจำลองถ้าไม่มี)
        local loadFunc = loadstring
        if not loadFunc then
            return false, "Executor ของคุณไม่รองรับคำสั่ง loadstring"
        end
        
        -- คอมไพล์โค้ด
        local func, compileError = loadFunc(codeString)
        if not func then
            return false, "Syntax Error: " .. tostring(compileError)
        end
        
        -- สร้างสภาพแวดล้อมจำลอง (Sandbox) ให้สคริปต์นี้เข้าถึง RYS ได้
        -- (ใช้ setfenv ถ้าทำได้ แต่ปกติ loadstring executor จะรันใน environment เดิมอยู่แล้ว)
        if setfenv then
            local env = getfenv(func)
            env.RYS = RYS
            pcall(setfenv, func, env)
        end
        
        -- รันโค้ดและดักจับ Error
        local success, runError = pcall(func)
        if success then
            RYS.Notify("Console", "✅ รันสคริปต์สำเร็จ!", 2)
            return true, "Success: Script executed without errors."
        else
            return false, "Runtime Error: " .. tostring(runError)
        end
    end

    RYS.RegisterModule("MiniConsole", Console)
    return Console
end
