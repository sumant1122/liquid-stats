# LiquidStats 🪟⚡

A lightweight, native **floating frosted-glass system monitor** for macOS built with Swift and SwiftUI.

![LiquidStats](https://img.shields.io/badge/macOS-14.0%2B-blue?style=flat-square&logo=apple)
![Swift](https://img.shields.io/badge/Swift-6.0%2B-orange?style=flat-square&logo=swift)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)

---

<img width="836" height="530" alt="Liquidstats" src="https://github.com/user-attachments/assets/fb570a05-90b9-4f8c-9368-f28be7e85e1a" />



## ✨ Features

- **Liquid Frosted Glass (`.ultraThinMaterial`)**: Real-time translucent blur that adapts beautifully over dark and light windows/wallpapers.
- **True Floating Window**: Borderless, floating level (`NSWindow.Level.floating`) that can join all virtual Desktops/Spaces.
- **Draggable Anywhere**: Click and drag from any part of the glass background to position it on your display.
- **Dual Display Modes**:
  - **Expanded Mode**: Trio of radial gauges (CPU, GPU, RAM), live CPU sparkline graph, top resource-heavy processes, memory pressure, thermals & load averages, network speeds, Wi-Fi signal, disk metrics, and battery telemetry (Watts, Health %, Cycles).
  - **Compact Mode**: Ultra-slim horizontal floating pill showing core stats (CPU, GPU, RAM, Top App badge, Network, Battery).
- **Advanced System Diagnostics**:
  - **Apple Silicon GPU Utilization**: Live GPU core usage % via native `IOAccelerator` Metal performance statistics.
  - **Battery Health & Live Wattage**: Real-time power draw in Watts, Maximum Capacity Health %, and hardware cycle count via `AppleSmartBattery`.
  - **Top Resource Hogs**: Real-time top 3 processes with CPU usage % and mini load bars via Darwin `libproc`.
  - **Memory Pressure**: Native macOS VM pressure indicator (Normal 🟢 / Warning 🟡 / Critical 🔴) via kernel sysctl.
  - **Thermals & Health**: Real-time thermal headroom (Nominal, Fair, Hot, Throttling), 1-min system load average, and uptime.
  - **Wi-Fi Signal**: Live signal strength (RSSI in dBm) via `CoreWLAN`.
- **Zero Heavy Dependencies**:
  - No Electron or web-view overhead.
  - CPU, GPU & RAM queried directly via Darwin/Mach kernel C-APIs (`mach_host`, `IOAccelerator`, `host_statistics64`).
  - Network throughput measured via BSD `getifaddrs`.
  - Battery hardware telemetry tracked via `IOKit`.
- **Accessory App**:
  - Does not crowd your macOS Dock (`LSUIElement = true`).
  - Adds a subtle menu bar icon to easily toggle the window in and out of view.
- **Interactive Controls**:
  - **Pin Toggle**: Toggle between always-on-top (`.floating`) or standard window behavior.
  - **Context Menu**: Right-click anywhere on the glass to change refresh rate (0.5s, 1s, 2s, 5s), switch modes, or quit.

---

## ⚡ Performance & Benchmarks

LiquidStats queries macOS via direct in-memory Mach traps rather than spawning subshells (`top` or `ps`):

| Metric / Operation | Latency | Description |
| :--- | :---: | :--- |
| **Mach CPU Load Info** | **0.51 µs** | Direct kernel trap reading CPU counters |
| **Mach VM & Memory Pressure** | **1.46 µs** | In-memory VM statistics & `sysctl` |
| **Full 1s Tick Duration** | **~0.33 ms** | LiquidStats is **99.97% asleep** every second |
| **Memory Footprint (RSS)** | **~70 MB** | vs. 300–600 MB for typical Electron monitors |

👉 **Read the full benchmark report in [BENCHMARKS.md](BENCHMARKS.md)** or run `make benchmark` to test your own machine.

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
