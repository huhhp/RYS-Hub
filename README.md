# ⚡ RYS Ultimate Hub v4.0

> Made for Wanq by RYS — All-in-One Roblox Script Hub

## 🚀 วิธีใช้งาน

Execute แค่บรรทัดเดียวใน Executor:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/RYS-Hub/main/loader.lua"))()
```

> ⚠️ เปลี่ยน `YOUR_USERNAME` เป็น GitHub username ของคุณ

## 📱 Platform Support

| Platform | วิธีเปิด/ปิด Hub |
|----------|------------------|
| 💻 PC | กดปุ่ม `RightShift` หรือกดปุ่ม ⚡ |
| 📱 Mobile | กดปุ่ม ⚡ (ลากได้) |

## 📋 Modules (22 ตัว)

### 🎯 Combat
- **Aimbot** — ล็อคเป้าอัตโนมัติ (PC: คลิกขวาค้าง, Mobile: Auto)
- **ESP / Wallhack** — เห็นผู้เล่นทะลุกำแพง + ชื่อ/HP/ระยะ
- **Kill Aura** — โจมตีอัตโนมัติในรัศมีที่กำหนด
- **Hitbox Expander** — ขยาย hitbox ศัตรู

### 🏃 Movement
- **Fly Hack** — บินได้ (PC: WASD+Space/Ctrl, Mobile: Joystick+Jump)
- **Speed Hack** — วิ่งเร็ว
- **Noclip** — ทะลุกำแพง
- **Infinite Jump** — กระโดดไม่จำกัด
- **Freecam** — กล้องอิสระ (WASD+QE)

### 🛡️ Defense
- **God Mode** — ไม่ตาย
- **Invisibility** — ล่องหน
- **Anti-Kick** — ป้องกันการเตะออก
- **Anti-AFK** — ป้องกัน AFK timeout
- **Anti-Cheat Bypass** — 7 ชั้นป้องกัน

### 💰 Exploit
- **Remote Spy** — ดักจับ Remote Events/Functions
- **Auto Farm** — เก็บไอเทมอัตโนมัติ
- **Value Scanner** — สแกนค่าในเกม
- **Server Hop** — เปลี่ยน server
- **Bring All** — ดึงผู้เล่นทุกคนมาหา
- **Chat Spam** — ส่งข้อความซ้ำ
- **FOV Changer** — เปลี่ยนมุมมอง

## ⚡ Performance Optimizations (v4.0)

| เดิม (v3.1) | ใหม่ (v4.0) | ผลลัพธ์ |
|---|---|---|
| ESP: RenderStepped ทุกเฟรม | Heartbeat + Throttle 0.1s | **ลด CPU 83%** |
| AutoFarm: GetDescendants ทุก Heartbeat | Throttle 0.5s + Touch limit | **ลด CPU 97%** |
| Speed: RenderStepped ทุกเฟรม | Throttle 0.5s | **ลด CPU 97%** |
| Hitbox: RenderStepped ทุกเฟรม | Throttle 0.2s | **ลด CPU 88%** |
| Connection leak ทุก module | Connection Manager cleanup | **ลด Memory Leak 100%** |
| Pulse animation: task.spawn loop | TweenInfo RepeatCount=-1 | **ลด Thread 100%** |

## 📁 โครงสร้างไฟล์

```
RYS-Hub/
├── loader.lua              ← ไฟล์หลัก (execute ตัวนี้)
├── core/
│   ├── init.lua            ← State + Config + Utilities
│   └── connection.lua      ← Connection Manager + Throttle
├── modules/
│   ├── combat/             ← Aimbot, ESP, Kill Aura, Hitbox
│   ├── movement/           ← Fly, Speed, Noclip, InfJump, Freecam
│   ├── defense/            ← God Mode, Invisible, Anti-*
│   └── exploit/            ← Remote Spy, Auto Farm, Value Mod, etc.
├── gui/
│   ├── components.lua      ← Button/Section creators
│   ├── floating.lua        ← Floating toggle button
│   └── main.lua            ← Main GUI
└── README.md               ← ไฟล์นี้
```

## 🔧 Console Commands

เข้าถึงได้จาก Console (F9) หลังจากโหลดแล้ว:

```lua
-- ดูสถิติ Connection
ConnMgr:PrintStats()

-- ดู Anti-Cheat blocked remotes
RYS.Modules.AntiCheat.GetStats()

-- ดู Remote Spy logs
for i, log in ipairs(RYS.Modules.RemoteSpy.Logs) do
    print(i, log.Remote)
end

-- เปลี่ยนค่า Settings
RYS.Settings.AimbotFOV = 300
RYS.Settings.FlySpeed = 100
RYS.Settings.WalkSpeed = 80
RYS.Settings.HitboxSize = 20
RYS.Settings.KillAuraRange = 30
```

## 📝 Setup Guide

1. สร้าง GitHub Repository ชื่อ `RYS-Hub`
2. Upload ไฟล์ทั้งหมดตาม structure ด้านบน
3. เปลี่ยน `YOUR_USERNAME` ใน `loader.lua` เป็น username จริง
4. Execute `loadstring(...)()` ใน Executor

---

**⚡ RYS v4.0 — Faster. Cleaner. Stronger.**
