# ⚡ RYS Ultimate Hub v5.0 — Hardened Edition

> Made for Wanq by RYS — All-in-One Roblox Exploit Hub
> 
> **25 Modules** | **Multi-CDN** | **XOR Encryption** | **Local Cache** | **Mobile Support**

## 🚀 วิธีใช้งาน

Execute แค่บรรทัดเดียวใน Executor:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/huhhp/RYS-Hub/main/loader.lua"))()
```

## 📱 Platform Support

| Platform | วิธีเปิด/ปิด Hub |
|----------|------------------|
| 💻 PC | กดปุ่ม `RightShift` หรือกดปุ่ม ⚡ |
| 📱 Mobile | กดปุ่ม ⚡ (ลากได้) |

## 📋 Modules (25 ตัว)

### 🎯 Combat (4)
- **Aimbot** — ล็อคเป้าอัตโนมัติ + Bezier Humanization + Prediction
- **ESP / Wallhack** — เห็นผู้เล่นทะลุกำแพง + ชื่อ/HP/ระยะ
- **Kill Aura** — โจมตีอัตโนมัติในรัศมีที่กำหนด
- **Hitbox Expander** — ขยาย hitbox ศัตรู

### 🏃 Movement (5)
- **Fly Hack** — บินได้ (PC: WASD+Space/Ctrl, Mobile: Joystick+Jump)
- **Speed Hack** — เปลี่ยน WalkSpeed/JumpPower
- **Noclip** — ทะลุกำแพงและสิ่งกีดขวาง
- **Infinite Jump** — กระโดดกลางอากาศไม่จำกัด
- **Freecam** — กล้องอิสระ (WASD+QE)

### 🛡️ Defense (5)
- **God Mode** — ล็อกเลือดไม่ตาย
- **Invisibility** — ล่องหนจากผู้เล่นอื่น
- **Anti-Kick** — สกัดกั้น Remote Kick
- **Anti-AFK** — ป้องกัน AFK timeout
- **Anti-Cheat Bypass** — 7-Layer AC Bypass

### 💰 Exploit (11)
- **Remote Spy** — ดักจับ + Replay Remote Events/Functions
- **Auto Farm** — Multi-method auto collect + Teleport
- **Value Scanner** — สแกนค่าในเกม
- **Server Hop** — เปลี่ยน server อัตโนมัติ
- **Bring All** — ดึงผู้เล่นทุกคนมาหา
- **Chat Spam** — ส่งข้อความซ้ำ
- **FOV Changer** — เปลี่ยนมุมมอง
- **🔓 GamePass Bypass** — Hook ownership checks (3 วิธี: Namecall + DirectHook + GC Scan)
- **🔑 Unlock All Items** — Clone Tools + Patch Attributes + Fire Unlock Remotes
- **📦 Item Spawner** — Deep-scan + Catalog + Spawn by name/index/all
- **🔁 Dupe Engine** — 5 วิธี (Clone, Drop, Remote Replay, Desync, Overflow)

## ⚡ Performance Optimizations

| เดิม | ใหม่ (v5.0) | ผลลัพธ์ |
|------|-------------|---------|
| ESP: RenderStepped ทุกเฟรม | Heartbeat + Throttle 0.1s | **ลด CPU 83%** |
| AutoFarm: GetDescendants ทุก beat | Throttle 0.5s + Touch limit | **ลด CPU 97%** |
| Connection leak ทุก module | Connection Manager cleanup | **ลด Memory Leak 100%** |
| Pulse animation: task.spawn loop | TweenInfo RepeatCount=-1 | **ลด Thread 100%** |

## 🔒 Security Features (v5.0)

- **Multi-CDN Failover** — 3 CDN sources + Local Cache backup
- **XOR Encryption** — ถอดรหัสทราฟฟิกแบบ Dynamic Bitwise XOR
- **Metatable Spoofing** — ซ่อน RYS จาก Anti-Cheat (__index, __namecall hook)
- **Debug Traceback Spoofing** — ส่ง traceback หลอกกลับ
- **GUI Protection** — syn.protect_gui / gethui() / CoreGui fallback
- **Weak Table GC** — ป้องกัน Memory Leak ด้วย weak reference

## 📁 โครงสร้างไฟล์

```
RYS-Hub/
├── loader.lua                  ← Entry Point (execute ตัวนี้)
├── core/
│   ├── init.lua                ← State + Config + Math + Security
│   └── connection.lua          ← Connection Manager + Throttle
├── modules/
│   ├── combat/                 ← Aimbot, ESP, Kill Aura, Hitbox
│   ├── movement/               ← Fly, Speed, Noclip, InfJump, Freecam
│   ├── defense/                ← God Mode, Invisible, Anti-*
│   └── exploit/                ← Remote Spy, Auto Farm, GamePass, Dupe, etc.
├── gui/
│   ├── components.lua          ← UI Component Factory
│   ├── floating.lua            ← Floating toggle button
│   └── main.lua                ← Main Dashboard (5 tabs)
├── README.md                   ← ไฟล์นี้
├── PROJECT_CONTEXT.md          ← AI Handoff Document
└── DEVELOPMENT_ROADMAP.md      ← แผนพัฒนาต่อ
```

## 🔧 Console Commands (F9)

```lua
-- ดูสถิติ Connection
ConnMgr:PrintStats()

-- ดู Remote Spy logs
for i, log in ipairs(RYS.Modules.RemoteSpy.Logs) do print(i, log.Remote) end

-- เปลี่ยนค่า Settings
RYS.Settings.AimbotFOV = 300
RYS.Settings.FlySpeed = 100

-- Dupe เฉพาะ item
RYS.Modules.Dupe.CloneDupe("Sword", 10)
RYS.Modules.Dupe.OverflowDupe(100)

-- Spawn item ตามชื่อ
RYS.Modules.ItemSpawn.SpawnByName("Sword")
RYS.Modules.ItemSpawn.Scan()

-- ดู GamePass spoof log
for i, log in ipairs(RYS.Modules.GamePass.SpoofLog) do print(i, log.Type, log.Id) end
```

## 🤝 AI Development

โปรเจกต์นี้ออกแบบให้ **AI ตัวไหนก็ทำงานต่อได้**:
- 📖 อ่าน `PROJECT_CONTEXT.md` เพื่อเข้าใจสถาปัตยกรรม
- 🗺️ อ่าน `DEVELOPMENT_ROADMAP.md` เพื่อดูแผนพัฒนา
- 🧠 อ่าน `C:\AI\memory\memory-store.json` เพื่อดู context

---

**⚡ RYS v5.0 — Faster. Harder. Stronger.**
