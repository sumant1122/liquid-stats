# LiquidStats 🪟⚡

A lightweight, native **floating frosted-glass system monitor** for macOS built with Swift and SwiftUI.

![LiquidStats](https://img.shields.io/badge/macOS-14.0%2B-blue?style=flat-square&logo=apple)
![Swift](https://img.shields.io/badge/Swift-6.0%2B-orange?style=flat-square&logo=swift)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)

---

<img width="850" height="536" alt="Screenshot 2026-10-14 at 9 51 26 PM" src="https://github.com/user-attachments/assets/cd37b234-68de-45b0-a40c-301866da4ae8" />


## ✨ Features

- **Liquid Frosted Glass (`.ultraThinMaterial`)**: Real-time translucent blur that adapts beautifully over dark and light windows/wallpapers.
- **True Floating Window**: Borderless, floating level (`NSWindow.Level.floating`) that can join all virtual Desktops/Spaces.
- **Draggable Anywhere**: Click and drag from any part of the glass background to position it on your display.
- **Dual Display Modes**:
  - **Expanded Mode**: Full radial gauges, live CPU activity sparkline graph, top resource-heavy processes, memory pressure, thermals & load averages, network speeds, Wi-Fi signal, disk metrics, and battery status.
  - **Compact Mode**: Ultra-slim horizontal floating pill showing core stats (CPU, RAM, Top App badge, Network, Battery).
- **Advanced System Diagnostics**:
  - **Top Resource Hogs**: Real-time top 3 processes with CPU usage % and mini load bars via Darwin `libproc`.
  - **Memory Pressure**: Native macOS VM pressure indicator (Normal 🟢 / Warning 🟡 / Critical 🔴) via kernel sysctl.
  - **Thermals & Health**: Real-time thermal headroom (Nominal, Fair, Hot, Throttling), 1-min system load average, and uptime.
  - **Wi-Fi Signal**: Live signal strength (RSSI in dBm) via `CoreWLAN`.
- **Zero Heavy Dependencies**:
  - No Electron or web-view overhead.
  - CPU & RAM queried directly via Darwin/Mach kernel C-APIs (`mach_host`, `host_statistics64`).
  - Network throughput measured via BSD `getifaddrs`.
  - Battery/power source tracked via `IOKit.ps`.
- **Accessory App**:
  - Does not crowd your macOS Dock (`LSUIElement = true`).
  - Adds a subtle menu bar icon to easily toggle the window in and out of view.
- **Interactive Controls**:
  - **Pin Toggle**: Toggle between always-on-top (`.floating`) or standard window behavior.
  - **Context Menu**: Right-click anywhere on the glass to change refresh rate (0.5s, 1s, 2s, 5s), switch modes, or quit.

---

## 🚀 Quick Start

### Build & Run
From the terminal, run:
```bash
./run.sh
```
Or using `make`:
```bash
make run
```

### Stop
```bash
make stop
```

---

## 🛠️ Project Structure

```
Mac Ideas/
├── Makefile                     # Build & run shortcuts
├── README.md                    # Documentation
├── run.sh                       # One-click launch script
├── .gitignore                   # Git ignore rules
└── GlassHUD/
    ├── build.sh                 # Swift compiler & codesign script
    ├── Info.plist               # App bundle configuration (LSUIElement)
    └── Sources/
        ├── App/
        │   ├── AppDelegate.swift              # App lifecycle & menu bar status item
        │   ├── FloatingWindowController.swift # Borderless NSWindow with .floating level
        │   └── main.swift                     # Entry point
        ├── Metrics/
        │   ├── Models.swift                   # Data models for CPU, RAM, Net, Disk, Battery
        │   ├── CPUMonitor.swift               # Mach host CPU load & history tracker
        │   ├── MemoryMonitor.swift            # Mach VM statistics (used, wired, compressed)
        │   ├── NetworkMonitor.swift           # BSD getifaddrs network rate calculator
        │   ├── DiskMonitor.swift              # File system size & free space
        │   ├── BatteryMonitor.swift           # IOKit power source & charging state
        │   └── SystemMonitor.swift            # ObservableObject coordinating update loops
        └── Views/
            ├── CircularGaugeView.swift        # Radial animated gauge with glowing arc
            ├── SparklineGraphView.swift       # Live CPU activity graph with gradient fill
            ├── MetricCardView.swift           # Sleek cards for Network, Disk, and Battery
            └── GlassHUDView.swift             # Main frosted glass HUD with mode toggles
```

---

## ⌨️ Controls & Gestures

| Action | How-To |
| :--- | :--- |
| **Move Window** | Click and drag anywhere on the glass background |
| **Toggle Mode** | Click the resize icon (`⤢`) or right-click → *Compact Mode* |
| **Pin / Unpin** | Click the pin icon (`📌`) in header or right-click |
| **Toggle Visibility** | Click the gauge icon in the macOS top menu bar |
| **Change Refresh Rate** | Right-click → *Update Speed* (0.5s, 1.0s, 2.0s, 5.0s) |
| **Quit** | Click the `✕` button or right-click → *Quit GlassHUD* |
