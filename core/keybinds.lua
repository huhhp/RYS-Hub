--[[
    RYS Hub — Keybind Manager v5.0
    
    Features:
    1. ผูกปุ่มเข้ากับ Module (Toggle หรือ Execute)
    2. InputBegan Listener ตัวเดียว (Performance +)
    3. ข้ามการทำงานพิมพ์ข้อความใน Chat (gameProcessed)
--]]

return function(RYS, ConnMgr)
    local Keybinds = {}
    local MODULE_NAME = "Keybinds"
    
    local UIS = RYS.Services.UserInputService
    
    -- Initialize State
    if type(RYS.Keybinds) ~= "table" then
        RYS.Keybinds = {} -- Format: { ["ModuleName"] = Enum.KeyCode.X }
    end

    function Keybinds.SetBind(moduleName, keyCode)
        if keyCode == Enum.KeyCode.Unknown or keyCode == nil then
            RYS.Keybinds[moduleName] = nil
        else
            RYS.Keybinds[moduleName] = keyCode
        end
        -- trigger save
        if RYS.Modules.Config then
            pcall(function() RYS.Modules.Config.Save(true) end)
        end
    end

    function Keybinds.GetBind(moduleName)
        return RYS.Keybinds[moduleName]
    end

    function Keybinds.GetBindName(moduleName)
        local key = RYS.Keybinds[moduleName]
        return key and key.Name or "None"
    end

    -- ═══════════════════════════════════════
    -- GLOBAL INPUT LISTENER
    -- ═══════════════════════════════════════
    function Keybinds.Init()
        -- ล้างตัวเก่าถ้ามี
        ConnMgr:DisconnectAll(MODULE_NAME)
        
        ConnMgr:AddConnection(MODULE_NAME, UIS.InputBegan, function(input, gameProcessed)
            -- ข้ามถ้าผู้เล่นกำลังพิมพ์แชท หรือกดปุ่มเมนูเกม
            if gameProcessed then return end
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            
            -- ข้ามปุ่มสลับเมนูหลัก (RightShift) - จัดการไว้ที่ loader.lua แล้ว
            if input.KeyCode == Enum.KeyCode.RightShift then return end

            local pressedKey = input.KeyCode
            
            -- หาว่าปุ่มนี้ผูกกับ Module ไหนบ้าง
            for modName, boundKey in pairs(RYS.Keybinds) do
                if boundKey == pressedKey then
                    local mod = RYS.Modules[modName]
                    if mod then
                        -- ถ้าเป็นแบบ Toggle
                        if type(mod.Toggle) == "function" then
                            local currentState = RYS.Enabled[modName]
                            -- สลับสถานะ (Flip state)
                            -- แต่อาจจะต้องอัปเดต UI ด้วย, จะจัดการผ่าน Event หรืออัปเดตโดยตรง 
                            -- แต่เพื่อให้ชัวร์ เราจะ Toggle logic ไว้
                            mod.Toggle(not currentState)
                            
                            -- ถ้า GUI อยู่ โพสต์แจ้งเตือนไปที่ GUI ให้ปุ่มอัปเดตสถานะ
                            if RYS.GUI then
                                local btnName = modName .. "_Toggle"
                                -- เราไม่สามารถเข้าถึง state ภายในปิดของปุ่มใน components ได้ง่ายๆ 
                                -- ยกเว้นว่าเราส่งสัญญาณ หรือสร้าง Registry
                                -- เพื่อความชัวร์ เราแค่ Toggle ธรรมดา (UI อาจไม่ sync จนกว่าจะเปิดเมนู)
                            end
                        -- ถ้าเป็นแบบ Execute
                        elseif type(mod.Execute) == "function" then
                            mod.Execute()
                        end
                    end
                end
            end
        end)
    end

    -- เริ่มทำงานอัตโนมัติ
    if not RYS.IsMobile then
        Keybinds.Init()
    end

    RYS.RegisterModule("Keybinds", Keybinds)
    return Keybinds
end
