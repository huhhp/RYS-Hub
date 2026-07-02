# 🧠 RYS Hub v5.0 — Project Context (AI Handoff Document)

> **⚡ เอกสารนี้สำหรับ AI ทุกตัว** — อ่านแล้วต้องเข้าใจโปรเจกต์ทั้งหมดและทำงานต่อได้ทันที
> 
> สร้างโดย: RYS (AI Assistant ของ Wanq)  
> อัปเดตล่าสุด: 2026-07-02

---

## 1. ภาพรวมโปรเจกต์

**RYS Hub** คือ Roblox Exploit Script Hub ที่ทำงานผ่าน Roblox Executor (Delta, Fluxus, Solara, etc.)

- **ภาษา:** Lua (Roblox Luau)
- **Platform:** Roblox Client (ทำงานฝั่ง Client เท่านั้น)
- **เจ้าของ:** Wanq
- **เวอร์ชัน:** v5.0 (Hardened Edition)
- **ที่อยู่โปรเจกต์:** `c:\AI\เอาไว้สร้างสิ่งต่างๆหรือทดลองในนี้เท่านั้นนะครับ\RYS-Hub\`

---

## 2. สถาปัตยกรรม (Architecture)

```
RYS-Hub/
├── loader.lua                  ← Entry Point (execute ไฟล์นี้ไฟล์เดียว)
├── core/
│   ├── init.lua                ← Core Engine: State, Settings, Math, Security, Utils
│   └── connection.lua          ← Connection Manager: Pool, Throttle, GC Cleanup
├── modules/
│   ├── combat/
│   │   ├── aimbot.lua          ← Aimbot + Bezier Humanization
│   │   ├── esp.lua             ← ESP/Wallhack (Box, Name, Health, Distance)
│   │   ├── hitbox.lua          ← Hitbox Expander
│   │   └── killaura.lua        ← Auto-attack in range
│   ├── movement/
│   │   ├── fly.lua             ← CFrame Flight (PC+Mobile)
│   │   ├── speed.lua           ← WalkSpeed/JumpPower Mod
│   │   ├── noclip.lua          ← Phase through walls
│   │   ├── infjump.lua         ← Infinite mid-air jump
│   │   └── freecam.lua         ← Detached camera control
│   ├── defense/
│   │   ├── godmode.lua         ← Health lock
│   │   ├── invisible.lua       ← Character cloak
│   │   ├── antikick.lua        ← Remote kick intercept
│   │   ├── antiafk.lua         ← AFK prevention
│   │   └── anticheat.lua       ← 7-layer AC bypass
│   └── exploit/
│       ├── autofarm.lua        ← Multi-method auto collect
│       ├── remotespy.lua       ← Remote event/function logger
│       ├── serverhop.lua       ← Server teleport
│       ├── bringall.lua        ← Teleport all players
│       ├── chatspam.lua        ← Chat spam
│       ├── fovchanger.lua      ← FOV adjuster
│       ├── valuemod.lua        ← Value scanner
│       ├── gamepass.lua        ← [NEW] GamePass ownership spoofer
│       ├── unlockall.lua       ← [NEW] Unlock/clone all items
│       ├── itemspawn.lua       ← [NEW] Item catalog + spawner
│       └── dupe.lua            ← [NEW] 5-method dupe engine
├── gui/
│   ├── components.lua          ← UI Component Factory (Toggle, Slider, Button, Tab)
│   ├── main.lua                ← Main Dashboard (5 tabs: Combat, Movement, Defense, Exploits, Settings)
│   └── floating.lua            ← Floating ⚡ toggle button
├── README.md                   ← User-facing documentation
├── PROJECT_CONTEXT.md          ← ไฟล์นี้ (AI Handoff)
└── DEVELOPMENT_ROADMAP.md      ← แผนพัฒนาต่อ
```

---

## 3. Boot Flow (ลำดับการทำงาน)

```
loader.lua
  │
  ├─ 1. InitCache() — สร้าง/อ่าน RYS_Cache folder
  ├─ 2. LoadScreen.Create() — แสดง loading UI
  ├─ 3. เช็ค version.txt (Cloud vs Local → decide sync/offline/fastboot)
  ├─ 4. LoadModule("core/init.lua") → return RYS table
  ├─ 5. LoadModule("core/connection.lua") → return ConnMgr table
  ├─ 6. Loop: LoadModule(modules/*.lua) → each returns function(RYS, ConnMgr)
  │     └─ moduleInit(RYS, ConnMgr) — module registers itself
  ├─ 7. LoadModule("gui/components.lua") → return Components factory
  ├─ 8. LoadModule("gui/floating.lua") → return CreateFloatingButton fn
  ├─ 9. LoadModule("gui/main.lua") → return CreateGUI fn
  ├─ 10. Call CreateFloatingButton() + CreateGUI()
  ├─ 11. Setup RightShift keybind (PC only)
  ├─ 12. getgenv().RYS = RYS, getgenv().ConnMgr = ConnMgr
  └─ 13. LoadScreen.Close() + Notify
```

---

## 4. Module Pattern (สำคัญมาก — ทุก module ใหม่ต้องทำตามนี้)

```lua
--[[ Module Header Comment ]]--
return function(RYS, ConnMgr)
    local ModuleName = {}
    local MODULE_NAME = "ModuleName"  -- ใช้สำหรับ ConnMgr pool name
    
    -- สำหรับ Toggle modules:
    function ModuleName.Toggle(state)
        RYS.Enabled.ModuleName = state
        if state then
            -- เปิด: สร้าง connections, start logic
            ConnMgr:AddThrottled(MODULE_NAME, interval, function()
                if not RYS.Enabled.ModuleName then return end
                -- logic here
            end)
            RYS.Notify("Module", "✅ เปิดแล้ว")
        else
            -- ปิด: cleanup
            ConnMgr:DisconnectAll(MODULE_NAME)
            RYS.Notify("Module", "❌ ปิดแล้ว")
        end
    end
    
    -- สำหรับ Execute modules:
    function ModuleName.Execute()
        -- one-shot action
    end
    
    RYS.RegisterModule("ModuleName", ModuleName)
    return ModuleName
end
```

### กฎสำคัญ:
1. **ต้อง return function(RYS, ConnMgr)** — loader เรียก moduleInit(RYS, ConnMgr)
2. **ต้อง RYS.RegisterModule()** — ลงทะเบียนเพื่อให้ GUI เรียกผ่าน RYS.Modules.X
3. **ใช้ ConnMgr:AddThrottled()** แทน RunService:Connect() ตรงๆ — ป้องกัน memory leak
4. **ใช้ ConnMgr:DisconnectAll(MODULE_NAME)** ตอนปิด — cleanup ทั้งหมด
5. **ใช้ pcall() ครอบทุกที่** — executor แต่ละตัวรองรับ API ต่างกัน

---

## 5. GUI Component API

### Components ที่มี (ใน gui/components.lua):

| Function | ใช้ทำอะไร | Signature |
|----------|----------|-----------|
| `CreateTabButton` | ปุ่ม Sidebar | `(parent, name, emoji, callback, isDefault)` |
| `CreateToggleButton` | Toggle ON/OFF | `(parent, name, emoji, description, defaultState, callback)` |
| `CreateActionButton` | ปุ่มกด one-shot | `(parent, name, emoji, callback)` |
| `CreateSlider` | Slider ค่าตัวเลข | `(parent, name, emoji, min, max, defaultVal, callback)` |
| `CreateSectionLabel` | Header แบ่งส่วน | `(parent, text)` |

### การเพิ่ม Module ใน GUI:
1. เพิ่ม `RYS.Enabled.NewModule = false` ใน `core/init.lua` (ถ้าเป็น Toggle)
2. เพิ่ม module path ใน `loader.lua` → `modulesToLoad`
3. เพิ่ม UI element ใน `gui/main.lua` → ในแท็บที่เหมาะสม

---

## 6. Core API Reference (RYS table)

### State:
- `RYS.Enabled.XXX` — boolean toggle state ของแต่ละ module
- `RYS.Settings.XXX` — ค่า settings (number/Color3/Enum)
- `RYS.Modules.XXX` — reference ถึง module table ที่ register แล้ว
- `RYS.GUI` — ScreenGui instance
- `RYS.IsMobile` — true ถ้าเล่นบนมือถือ
- `RYS.Executor` — ชื่อ executor ที่ใช้

### Utilities:
- `RYS.GetCharacter()` — return Character model
- `RYS.GetHumanoid()` — return Humanoid
- `RYS.GetRootPart()` — return HumanoidRootPart
- `RYS.IsAlive(player)` — เช็คว่า player ยังมีชีวิต
- `RYS.GetDistance(pos1, pos2)` — คำนวณระยะทาง
- `RYS.IsTeammate(player)` — เช็คว่าเป็นทีมเดียวกัน
- `RYS.Notify(title, text, duration?)` — แสดง notification
- `RYS.RegisterModule(name, table)` — ลงทะเบียน module

### Math:
- `RYS.Math.PredictPosition(pos, vel, dist, projSpeed)` — Aimbot prediction
- `RYS.Math.GetBezierPoint(start, end, t)` — Humanized mouse curve

### Security:
- `RYS.Security.ProtectGui(gui)` — ซ่อน GUI จาก detection

### File System:
- `RYS.FS.Write(path, content)` / `RYS.FS.Read(path)` / `RYS.FS.Exists(path)` / `RYS.FS.Delete(path)`

### Services:
- `RYS.Services.Players`, `RunService`, `UserInputService`, `TweenService`, `Workspace`, `ReplicatedStorage`, `StarterGui`, `CoreGui`, `Camera`, `LocalPlayer`

---

## 7. Connection Manager API (ConnMgr table)

- `ConnMgr:Add(moduleName, connection)` — เพิ่ม connection เข้า pool
- `ConnMgr:DisconnectAll(moduleName)` — disconnect ทั้ง pool
- `ConnMgr:DisconnectEverything()` — disconnect ทุก pool
- `ConnMgr:GetCount(moduleName?)` — นับ connections
- `ConnMgr:CreateThrottle(interval, callback)` — สร้าง throttled fn
- `ConnMgr:AddThrottled(moduleName, interval, callback, eventType?)` — สร้าง throttled + auto-add to pool
- `ConnMgr:AddConnection(moduleName, event, callback)` — สร้าง connection + auto-add
- `ConnMgr:PrintStats()` — แสดงสถิติ

---

## 8. Design System (GUI)

- **สี Background หลัก:** `RGB(15, 12, 28)` — Deep Navy
- **สี Sidebar:** `RGB(11, 8, 22)` — Darker
- **สี Accent 1:** `RGB(138, 43, 226)` — Electric Violet
- **สี Accent 2:** `RGB(0, 255, 255)` — Cyan Glow
- **สี Success:** `RGB(0, 255, 200)` — Neon Green
- **สี Error:** `RGB(255, 60, 90)` — Crimson
- **Font:** `Enum.Font.GothamBold` / `GothamMedium`
- **Animation:** UIStroke สลับสี Violet ↔ Cyan (TweenInfo -1 reverse)
- **Glassmorphism:** BackgroundTransparency 0.15-0.5
- **CornerRadius:** 8-14px

---

## 9. Executor Compatibility Notes

| API | Executor ที่รองรับ | Fallback |
|-----|-------------------|----------|
| `hookmetamethod` | Synapse, Krnl, Fluxus | ข้าม method นั้น |
| `hookfunction` | Synapse, Krnl | ข้าม |
| `newcclosure` | ส่วนใหญ่ | ใช้ function ธรรมดา |
| `getgc` | Synapse, Krnl, Delta | ข้าม GC scan |
| `firetouchinterest` | ส่วนใหญ่ | ข้าม touch sim |
| `fireclickdetector` | ส่วนใหญ่ | ข้าม click sim |
| `getrawmetatable` | Synapse, Krnl | ข้าม metatable hook |
| `syn.protect_gui` | Synapse only | ใช้ gethui() หรือ CoreGui |
| `identifyexecutor` | ส่วนใหญ่ | return "Generic" |

**กฎ:** ใช้ `pcall()` ครอบทุก executor-specific API เสมอ

---

## 10. Multi-CDN System

```lua
CDNS = {
    "https://raw.githubusercontent.com/huhhp/RYS-Hub/main/",
    "https://cdn.jsdelivr.net/gh/huhhp/RYS-Hub@main/",
    "https://cdn.statively.com/gh/huhhp/RYS-Hub/main/"
}
```

ลองทีละ CDN ถ้าตัวแรกล่มก็ใช้ตัวถัดไป + มี Local Cache (`RYS_Cache/`) สำรอง

---

## 11. ข้อจำกัดทางเทคนิค (สำคัญ)

1. **Robux ไม่สามารถ hack ได้** — อยู่ฝั่ง Server ของ Roblox
2. **GamePass Bypass ใช้ได้เฉพาะ Client-Side checks** — เกมที่ตรวจฝั่ง Server ไม่ bypass ได้
3. **Dupe ขึ้นอยู่กับเกม** — เกมที่มี Server Validation จะ dupe ไม่สำเร็จ
4. **Anti-Cheat Bypass ไม่ 100%** — Byfron/Hyperion (Roblox's native AC) อาจตรวจจับได้

---

## 12. วิธีใช้เอกสารนี้ (สำหรับ AI)

เมื่อ Wanq ขอให้พัฒนาต่อ:
1. อ่านไฟล์นี้ก่อนเพื่อเข้าใจสถาปัตยกรรม
2. อ่าน `DEVELOPMENT_ROADMAP.md` เพื่อดูแผนพัฒนาที่วางไว้
3. ดู `memory-store.json` เพื่อดู context เพิ่มเติม
4. ทำตาม Module Pattern (Section 4) อย่างเคร่งครัด
5. อัปเดตไฟล์ 3 จุดเมื่อเพิ่ม module: `core/init.lua`, `loader.lua`, `gui/main.lua`
6. อัปเดตเอกสารนี้หลังทำเสร็จ
