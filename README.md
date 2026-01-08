# LuaU Helper Services

A collection of lightweight, reusable **LuaU helper services** designed to simplify common gameplay, client, and engine-level patterns in Roblox projects.  
Each service is modular, opt-in, and built to scale cleanly from prototyping to production.

---

## 📦 Services Overview

### 🧹 CacheCleanUp.lua
Flushes expired (TTL-based) entries from in-game caches.

**Use cases**
- Memory-sensitive systems
- Temporary data stores
- Cooldowns and time-based values

**Key features**
- Time-to-live support
- Manual and automatic flushing
- Low overhead

---

### 🏷️ Collections.lua
A centralized, tag-based logic binder for instances.

**Use cases**
- Binding behavior to tagged objects
- Cleaner alternative to scattered `CollectionService` logic
- Decoupled gameplay systems

**Key features**
- Tag → callback binding
- Automatic handling of added/removed instances
- Clean lifecycle management

---

### 🗑️ Debris.lua
Enhanced object offloading with more control than Roblox’s built-in `Debris`.

**Use cases**
- Bulk cleanup
- Temporary effects
- Controlled destruction pipelines

**Key features**
- Bulk destroy methods
- Optional delays
- Predictable cleanup behavior

---

### 🐞 Debug.lua
Optional, environment-aware logging utilities.

**Use cases**
- Keeping production logs clean
- Structured debug output
- Feature-flagged logging

**Key features**
- Toggleable logging
- Log levels (info / warn / error)
- Zero-noise production mode

---

### 💻 Device.lua
Identifies client device type and responds to device changes.

**Use cases**
- Platform-specific UI
- Input logic branching
- Adaptive gameplay

**Key features**
- Detects Computer / Console / Mobile
- Change listeners
- Client-safe API

---

### 📳 Haptics.lua
Sends vibration feedback to supported client devices.

**Use cases**
- Combat feedback
- UI confirmation
- Immersion enhancements

**Key features**
- Motor-based vibration control
- Intensity and duration support
- Graceful fallback on unsupported devices

---

### 🎥 Camera.lua
Camera manipulation effects and utilities.

**Use cases**
- Screen shake
- FOV changes
- Cinematic effects

**Key features**
- Non-destructive camera effects
- Stackable modifiers
- Smooth transitions

---

### 🔊 Sounds.lua
Unified 2D and 3D sound management.

**Use cases**
- Spatial audio
- UI sounds
- Centralized sound control

**Key features**
- 2D and 3D playback
- Automatic cleanup
- Volume and rolloff control

---

## 🧩 Installation

1. Copy the service files into a shared directory (e.g. `ReplicatedStorage/Services`)
2. Require only what you need:

```lua
// Basic Usage
local Camera = require(ReplicatedStorage.Services.Camera)
local Sounds = require(ReplicatedStorage.Services.Sounds)
