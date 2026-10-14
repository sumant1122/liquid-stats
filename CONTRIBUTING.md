# Contributing to LiquidStats 💧

Thank you for your interest in contributing to **LiquidStats**! We welcome bug reports, design ideas, feature requests, and code contributions.

---

## 🧭 Project Philosophy

LiquidStats is designed to be:
1. **Lightweight & Battery-Friendly**: Minimal CPU cycles (< 0.5% when idle), zero heavy runtime dependencies (no Electron, no web views).
2. **Native & Clean**: Built using pure Swift, SwiftUI, and AppKit with low-overhead Darwin Mach kernel C-APIs (`mach_host`, `proc_pidinfo`, `host_statistics64`).
3. **Visually Delightful**: Modern macOS design principles with liquid frosted glass (`.ultraThinMaterial`), subtle border gradients, and smooth spring animations.

---

## 🛠️ Local Development

### Prerequisites
* macOS 14.0+ (Sonoma, Sequoia, or later)
* Xcode Command Line Tools or Xcode (`xcode-select --install`)
* Swift 6.0+

### Building & Running
You don't need a complex Xcode project setup. You can build and test directly from the command line:

```bash
# Build the application
make build

# Launch the floating HUD
make run

# Stop running instance
make stop

# Clean build artifacts
make clean
```

---

## 🌿 Contribution Workflow

1. **Fork the repository** on GitHub.
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/<your-username>/liquid-stats.git
   cd liquid-stats
   ```
3. **Create a topic branch**:
   ```bash
   git checkout -b feature/my-cool-metric
   ```
4. **Make your changes**:
   - Keep metric sampling efficient (use Mach/Darwin kernel APIs rather than spawning shell processes like `top` or `ps`).
   - Maintain clean separation between `Metrics/` (engine) and `Views/` (UI).
   - Test both **Expanded Mode** and **Compact Mode**.
5. **Verify the build**:
   ```bash
   make build
   make run
   ```
6. **Commit your changes**:
   ```bash
   git commit -m "Add GPU utilization gauge"
   ```
7. **Push to your branch** and open a Pull Request against `main`.

---

## 🐛 Reporting Bugs

When reporting an issue, please include:
* macOS version (e.g. macOS 15.1 Sequoia)
* Mac model and chip (e.g. M2 Pro MacBook Pro, M3 iMac)
* Steps to reproduce the bug
* Expected vs actual behavior

---

## 📜 Code of Conduct

All contributors are expected to follow our [Code of Conduct](CODE_OF_CONDUCT.md).
