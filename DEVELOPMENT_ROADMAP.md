# 🗺️ RYS Hub — Development Roadmap

> แผนพัฒนาต่อสำหรับ AI ทุกตัว — เรียงตามลำดับความสำคัญ
> 
> อัปเดตล่าสุด: 2026-07-02
> สถานะ: ✅ = เสร็จแล้ว | 🔲 = ยังไม่ทำ | 🔧 = กำลังทำ

---

## สถานะปัจจุบัน: v5.0 (25 Modules)

### ✅ Modules ที่สร้างเสร็จแล้ว (25 ตัว)

#### Combat (4)
- ✅ Aimbot (Bezier + Prediction)
- ✅ ESP/Wallhack (Box + Name + HP + Distance)
- ✅ Kill Aura (Range-based auto attack)
- ✅ Hitbox Expander

#### Movement (5)
- ✅ Fly Hack (CFrame + Mobile joystick)
- ✅ Speed Hack (WalkSpeed mod)
- ✅ Noclip (Phase through walls)
- ✅ Infinite Jump
- ✅ Freecam (Detached camera)

#### Defense (5)
- ✅ God Mode (Health lock)
- ✅ Invisibility (Character cloak)
- ✅ Anti-Kick (Remote intercept)
- ✅ Anti-AFK
- ✅ Anti-Cheat Bypass (7-layer)

#### Exploit (11)
- ✅ Remote Spy (Log + Replay)
- ✅ Auto Farm (Multi-method + Teleport)
- ✅ Value Scanner
- ✅ Server Hop
- ✅ Bring All Players
- ✅ Chat Spam
- ✅ FOV Changer
- ✅ GamePass Bypass (3 hook methods)
- ✅ Unlock All Items (Scan + Clone + Patch)
- ✅ Item Spawner (Catalog + Search)
- ✅ Dupe Engine (5 methods)

#### Core & GUI
- ✅ Core Init (State + Security + Math)
- ✅ Connection Manager (Pool + Throttle)
- ✅ Multi-CDN Loader (3 CDN + Cache)
- ✅ GUI Components (Toggle, Slider, Action, Tab, Section)
- ✅ Main Dashboard (5 tabs)
- ✅ Floating Button

---

## ✅ Tier 1: ควรทำเป็นอันดับแรก (Foundation)

### 1.1 ✅ Config Save/Load System
**ไฟล์ที่ต้องสร้าง:** `core/config.lua`
**แก้ไข:** `core/init.lua`, `gui/main.lua`

**รายละเอียด:**
- บันทึก `RYS.Enabled` + `RYS.Settings` ลงไฟล์ JSON
- โหลดค่ากลับมาตอน boot (ใน loader.lua หลัง core init)
- ใช้ `RYS.FS.Write/Read` ที่มีอยู่แล้ว
- Path: `RYS_Config/settings.json`

**โค้ดตัวอย่าง:**
```lua
return function(RYS, ConnMgr)
    local Config = {}
    local CONFIG_PATH = "RYS_Config/settings.json"
    
    function Config.Save()
        local data = {
            Enabled = RYS.Enabled,
            Settings = {}
        }
        -- แปลง Color3/Enum เป็น string ก่อน save
        for k, v in pairs(RYS.Settings) do
            if typeof(v) == "Color3" then
                data.Settings[k] = {R=v.R*255, G=v.G*255, B=v.B*255}
            elseif typeof(v) == "EnumItem" then
                data.Settings[k] = tostring(v)
            else
                data.Settings[k] = v
            end
        end
        local json = game:GetService("HttpService"):JSONEncode(data)
        RYS.FS.Write(CONFIG_PATH, json)
    end
    
    function Config.Load()
        local content = RYS.FS.Read(CONFIG_PATH)
        if content then
            local data = game:GetService("HttpService"):JSONDecode(content)
            -- merge into RYS state
        end
    end
    
    RYS.RegisterModule("Config", Config)
    return Config
end
```

---

### 1.2 ✅ Keybind Manager
**ไฟล์ที่ต้องสร้าง:** `core/keybinds.lua`
**แก้ไข:** `gui/main.lua` (Settings tab)

**รายละเอียด:**
- ตาราง Keybind: `{ ModuleName = Enum.KeyCode.X }`
- GUI: ปุ่ม "Set Keybind" → กดปุ่มที่ต้องการ → บันทึก
- InputBegan listener ตัวเดียวที่ dispatch ไปทุก module
- Save/Load ร่วมกับ Config system

---

### 1.3 ✅ Profile/Preset System
**ไฟล์ที่ต้องสร้าง:** `core/profiles.lua`
**แก้ไข:** `gui/main.lua` (Settings tab)

**รายละเอียด:**
- Preset: "PVP Mode", "Farm Mode", "Stealth Mode"
- แต่ละ preset = snapshot ของ Enabled + Settings
- ปุ่ม Save/Load/Delete Preset ใน Settings tab
- Path: `RYS_Config/profiles/`

---

## 🔲 Tier 2: เพิ่มพลังอย่างมาก

### 2.1 ✅ Player List Panel
**ไฟล์ที่ต้องสร้าง:** `gui/playerlist.lua`
**แก้ไข:** `gui/main.lua` (เพิ่มแท็บ "Players")

**รายละเอียด:**
- แสดงรายชื่อผู้เล่นทุกคนในเซิร์ฟเวอร์
- แต่ละคน: ชื่อ, HP, Distance, Team
- ปุ่ม: Spectate, TP to, Copy Name, Kick (ถ้าเป็น admin)
- อัปเดตอัตโนมัติเมื่อมีคน join/leave

---

### 2.2 ✅ Teleport Waypoints
**ไฟล์ที่ต้องสร้าง:** `modules/movement/waypoints.lua`
**แก้ไข:** `gui/main.lua` (Movement tab)

**รายละเอียด:**
- ปุ่ม "Save Position" → บันทึกตำแหน่ง CFrame ปัจจุบัน
- ปุ่ม "TP to Waypoint" → teleport ไปตำแหน่งที่บันทึก
- รายการ waypoints แสดงใน GUI (ลบได้)
- Save ลงไฟล์ (ใช้ Config system)

---

### 2.3 ✅ Script Executor (Mini Console)
**ไฟล์ที่ต้องสร้าง:** `gui/console.lua`
**แก้ไข:** `gui/main.lua` (เพิ่มแท็บ "Console")

**รายละเอียด:**
- TextBox สำหรับพิมพ์ Lua code
- ปุ่ม "Execute" → loadstring(code)()
- Output log แสดงผลลัพธ์
- History: เก็บ code ที่เคยรัน

---

### 2.4 🔲 Game-Specific Module Loader
**ไฟล์ที่ต้องสร้าง:** `modules/games/` folder + loader logic
**แก้ไข:** `loader.lua`

**รายละเอียด:**
- ตรวจ `game.PlaceId` ตอน boot
- โหลด modules พิเศษสำหรับเกมยอดนิยม:
  - Blox Fruits: Auto-farm fruit, teleport island
  - Arsenal: Auto-aim specific, weapon unlocker
  - Murder Mystery 2: Reveal roles
  - Adopt Me: Dupe pets
  - Brookhaven: Unlock houses/cars
- โครงสร้าง: `modules/games/{gamename}/init.lua`

---

### 2.5 ✅ Notification Center
**ไฟล์ที่ต้องสร้าง:** `gui/notifications.lua`
**แก้ไข:** `core/init.lua` (แทน SetCore notification)

**รายละเอียด:**
- Custom notification UI (ไม่พึ่ง SetCore)
- Stack แสดงหลายอันพร้อมกัน
- Animation: Slide-in + Fade-out
- สี: Success (green), Error (red), Info (cyan), Warning (yellow)

---

## 🔧 Tier 3: UI/UX Premium (ทำแล้วบางส่วน)

### 3.1 ✅ Theme Engine
**ไฟล์ที่ต้องสร้าง:** `gui/themes.lua`
**แก้ไข:** `gui/components.lua`, `gui/main.lua`

**รายละเอียด:**
- ธีมที่รองรับ: Violet (default), Red, Blue, Green, Gold, Custom RGB
- ตาราง Theme: `{ Primary, Secondary, Accent, Text, Background }`
- Components อ่านสีจาก Theme table แทน hardcode
- ปุ่มสลับธีมใน Settings tab

---

### 3.2 🔲 Search Bar
**แก้ไข:** `gui/main.lua`

**รายละเอียด:**
- TextBox ที่ top ของ content area
- พิมพ์แล้วกรองแสดงเฉพาะ modules ที่ตรงกับคำค้น
- ค้นทั้งชื่อและ description

---

### 3.3 ✅ FPS/Ping/Memory Monitor Widget
**ไฟล์ที่ต้องสร้าง:** `gui/monitor.lua`

**รายละเอียด:**
- แถบ overlay เล็กๆ มุมจอ
- แสดง: FPS, Ping (ms), Memory (KB), Connection count
- Toggle ON/OFF ใน Settings
- ใช้ Throttled connection (อัปเดตทุก 1 วินาที)

---

## 🔲 Tier 4: Security ขั้นสูง

### 4.1 🔲 Whitelist System
**ไฟล์ที่ต้องสร้าง:** `core/whitelist.lua`
**แก้ไข:** `loader.lua`

**รายละเอียด:**
- ตรวจ UserId จาก whitelist บน GitHub (whitelist.json)
- ถ้าไม่อยู่ใน whitelist → แสดงข้อความปฏิเสธ + destroy
- Optional: HWID check (ถ้า executor รองรับ)

---

### 4.2 🔲 Anti-Screenshot
**ไฟล์ที่ต้องสร้าง:** `modules/defense/antiss.lua`

**รายละเอียด:**
- ซ่อน GUI ชั่วคราวเมื่อตรวจจับ screenshot
- ใช้ GuiService / ScreenGui.DisplayOrder manipulation

---

## 📋 วิธีเพิ่ม Feature ใหม่ (Checklist)

เมื่อ AI ตัวใดก็ตามจะเพิ่ม feature:

1. ☐ สร้างไฟล์ module ใน `modules/{category}/` ตาม Module Pattern
2. ☐ เพิ่ม `RYS.Enabled.NewModule = false` ใน `core/init.lua` (ถ้าเป็น Toggle)
3. ☐ เพิ่ม Settings ใหม่ใน `RYS.Settings` ถ้าจำเป็น
4. ☐ เพิ่ม `{ path = "...", name = "..." }` ใน `loader.lua` → `modulesToLoad`
5. ☐ เพิ่ม UI (Toggle/Button/Slider) ใน `gui/main.lua` → แท็บที่เหมาะสม
6. ☐ อัปเดต `README.md` → รายการ modules
7. ☐ อัปเดต `PROJECT_CONTEXT.md` → Architecture tree + Module count
8. ☐ อัปเดต roadmap นี้ → เปลี่ยน 🔲 เป็น ✅
9. ☐ อัปเดต `memory-store.json` ถ้ามี insight ใหม่

---

## 📊 สถิติโปรเจกต์

| Metric | ค่า |
|--------|-----|
| Total Modules | 25 |
| Total Files | 27 |
| Total Lines (ประมาณ) | ~3,500 |
| Categories | 4 (Combat, Movement, Defense, Exploit) |
| GUI Tabs | 5 (Combat, Movement, Defense, Exploits, Settings) |
| CDN Sources | 3 |
| Executor Supported | 7+ |
