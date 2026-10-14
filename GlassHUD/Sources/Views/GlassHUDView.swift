import SwiftUI

public struct GlassHUDView: View {
    @ObservedObject public var monitor: SystemMonitor
    @State private var isHovering = false
    
    public init(monitor: SystemMonitor) {
        self.monitor = monitor
    }
    
    public var body: some View {
        Group {
            if monitor.isCompactMode {
                compactLayout
            } else {
                expandedLayout
            }
        }
        .padding(monitor.isCompactMode ? 10 : 16)
        .background(
            RoundedRectangle(cornerRadius: monitor.isCompactMode ? 16 : 22, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.35), radius: 18, x: 0, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: monitor.isCompactMode ? 16 : 22, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.35),
                            Color.white.opacity(0.12),
                            Color.white.opacity(0.04)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.18)) {
                isHovering = hovering
            }
        }
        .contextMenu {
            contextMenuItems
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: monitor.isCompactMode)
    }
    
    // MARK: - Expanded Layout
    private var expandedLayout: some View {
        VStack(spacing: 12) {
            // Header Bar
            HStack(alignment: .center) {
                // Live Pulse Dot & Title
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 7, height: 7)
                        .shadow(color: .green.opacity(0.7), radius: 3)
                    
                    Text("GLASS HUD")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .tracking(1.2)
                        .foregroundColor(.white.opacity(0.85))
                }
                
                Spacer()
                
                // Header Action Buttons
                HStack(spacing: 6) {
                    // Pin Button
                    Button {
                        monitor.isPinned.toggle()
                    } label: {
                        Image(systemName: monitor.isPinned ? "pin.fill" : "pin.slash")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(monitor.isPinned ? .yellow : .white.opacity(0.4))
                            .frame(width: 20, height: 20)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .help(monitor.isPinned ? "Always on Top (Enabled)" : "Always on Top (Disabled)")
                    
                    // Compact / Expand Button
                    Button {
                        monitor.isCompactMode.toggle()
                    } label: {
                        Image(systemName: "arrow.up.right.and.arrow.down.left")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(width: 20, height: 20)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .help("Toggle Compact View")
                    
                    // Close Button
                    Button {
                        monitor.onCloseRequested?()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(width: 20, height: 20)
                            .background(Color.red.opacity(isHovering ? 0.6 : 0.2))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .help("Close HUD")
                }
            }
            
            // Primary Gauges Row (CPU & RAM)
            HStack(spacing: 16) {
                CircularGaugeView(
                    title: "Processor",
                    icon: "cpu",
                    percent: monitor.cpu.usagePercent,
                    subtitle: String(format: "Sys: %.0f%%", monitor.cpu.systemPercent),
                    gradient: [.cyan, .blue],
                    size: 84
                )
                
                CircularGaugeView(
                    title: "Memory",
                    icon: "memorychip",
                    percent: monitor.memory.usedPercent,
                    subtitle: monitor.memory.usedFormatted,
                    gradient: [.purple, .indigo],
                    size: 84
                )
            }
            .padding(.vertical, 2)
            
            // CPU Load History Sparkline Graph
            SparklineGraphView(
                data: monitor.cpu.history,
                title: "CPU ACTIVITY (RECENT)",
                gradient: [.cyan, .teal],
                height: 34
            )
            
            // Secondary Metric Cards
            VStack(spacing: 6) {
                // Network Down / Up Card
                HStack(spacing: 6) {
                    MetricCardView(
                        icon: "arrow.down",
                        iconColor: .mint,
                        title: "DOWNLOAD",
                        primaryValue: monitor.network.downloadFormatted
                    )
                    
                    MetricCardView(
                        icon: "arrow.up",
                        iconColor: .orange,
                        title: "UPLOAD",
                        primaryValue: monitor.network.uploadFormatted
                    )
                }
                
                // Disk Space Card
                MetricCardView(
                    icon: "internaldrive",
                    iconColor: .yellow,
                    title: "DISK FREE",
                    primaryValue: monitor.disk.freeFormatted,
                    secondaryValue: String(format: "%.0f%% used", monitor.disk.usedPercent)
                )
                
                // Battery Card (shown if laptop / battery exists)
                if monitor.battery.hasBattery {
                    MetricCardView(
                        icon: monitor.battery.isCharging ? "bolt.batteryblock.fill" : "battery.100percent",
                        iconColor: monitor.battery.levelPercent > 20 ? .green : .red,
                        title: "BATTERY",
                        primaryValue: "\(monitor.battery.levelPercent)%",
                        secondaryValue: monitor.battery.isCharging ? "Charging" : (monitor.battery.isPluggedIn ? "AC Power" : "On Battery")
                    )
                }
            }
        }
        .frame(width: 228)
    }
    
    // MARK: - Compact Mini Bar Layout
    private var compactLayout: some View {
        HStack(spacing: 12) {
            // Live Dot
            Circle()
                .fill(Color.green)
                .frame(width: 6, height: 6)
                .shadow(color: .green.opacity(0.8), radius: 2)
            
            // CPU Pill
            HStack(spacing: 4) {
                Image(systemName: "cpu")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.cyan)
                Text("\(Int(monitor.cpu.usagePercent.rounded()))%")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Divider()
                .frame(height: 12)
                .background(Color.white.opacity(0.15))
            
            // RAM Pill
            HStack(spacing: 4) {
                Image(systemName: "memorychip")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.purple)
                Text("\(Int(monitor.memory.usedPercent.rounded()))%")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Divider()
                .frame(height: 12)
                .background(Color.white.opacity(0.15))
            
            // Net Speed Pill
            HStack(spacing: 4) {
                Image(systemName: "arrow.down")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.mint)
                Text(monitor.network.downloadFormatted)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.9))
            }
            
            if monitor.battery.hasBattery {
                Divider()
                    .frame(height: 12)
                    .background(Color.white.opacity(0.15))
                
                HStack(spacing: 3) {
                    Image(systemName: monitor.battery.isCharging ? "battery.100percent.bolt" : "battery.100percent")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(monitor.battery.isCharging ? .green : .white.opacity(0.8))
                    Text("\(monitor.battery.levelPercent)%")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            
            // Expand Button
            Button {
                monitor.isCompactMode = false
            } label: {
                Image(systemName: "arrow.down.left.and.arrow.up.right")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(4)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .help("Expand HUD")
        }
    }
    
    // MARK: - Context Menu Items
    @ViewBuilder
    private var contextMenuItems: some View {
        Button(monitor.isPinned ? "Unpin Window" : "Pin Always on Top") {
            monitor.isPinned.toggle()
        }
        
        Button(monitor.isCompactMode ? "Expanded Mode" : "Compact Mode") {
            monitor.isCompactMode.toggle()
        }
        
        Divider()
        
        Menu("Update Speed") {
            Button("Fast (0.5s)") { monitor.refreshInterval = 0.5 }
            Button("Normal (1.0s)") { monitor.refreshInterval = 1.0 }
            Button("Eco (2.0s)") { monitor.refreshInterval = 2.0 }
            Button("Low Power (5.0s)") { monitor.refreshInterval = 5.0 }
        }
        
        Divider()
        
        Button("Quit GlassHUD") {
            monitor.onCloseRequested?()
        }
    }
}
