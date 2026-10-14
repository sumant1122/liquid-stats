import Foundation
import SwiftUI

public struct ProcessItem: Identifiable, Sendable {
    public var id: pid_t { pid }
    public var pid: pid_t
    public var name: String
    public var cpuPercent: Double
    
    public init(pid: pid_t, name: String, cpuPercent: Double) {
        self.pid = pid
        self.name = name
        self.cpuPercent = cpuPercent
    }
}

public struct CPUStats: Sendable {
    public var usagePercent: Double = 0.0
    public var userPercent: Double = 0.0
    public var systemPercent: Double = 0.0
    public var idlePercent: Double = 100.0
    public var history: [Double] = []
    
    public init(usagePercent: Double = 0.0, userPercent: Double = 0.0, systemPercent: Double = 0.0, idlePercent: Double = 100.0, history: [Double] = []) {
        self.usagePercent = usagePercent
        self.userPercent = userPercent
        self.systemPercent = systemPercent
        self.idlePercent = idlePercent
        self.history = history
    }
}

public enum MemoryPressureState: String, Sendable {
    case normal = "Normal"
    case warning = "Warning"
    case critical = "Critical"
    
    public var color: Color {
        switch self {
        case .normal: return .green
        case .warning: return .yellow
        case .critical: return .red
        }
    }
}

public struct MemoryStats: Sendable {
    public var usedBytes: UInt64 = 0
    public var totalBytes: UInt64 = 0
    public var usedPercent: Double = 0.0
    public var freeBytes: UInt64 = 0
    public var pressure: MemoryPressureState = .normal
    
    public var usedFormatted: String {
        ByteCountFormatter.string(fromByteCount: Int64(usedBytes), countStyle: .memory)
    }
    
    public var totalFormatted: String {
        ByteCountFormatter.string(fromByteCount: Int64(totalBytes), countStyle: .memory)
    }
    
    public init(usedBytes: UInt64 = 0, totalBytes: UInt64 = 0, usedPercent: Double = 0.0, freeBytes: UInt64 = 0, pressure: MemoryPressureState = .normal) {
        self.usedBytes = usedBytes
        self.totalBytes = totalBytes
        self.usedPercent = usedPercent
        self.freeBytes = freeBytes
        self.pressure = pressure
    }
}

public enum ThermalStateLabel: String, Sendable {
    case nominal = "Nominal"
    case fair = "Fair"
    case serious = "Hot"
    case critical = "Throttling"
    
    public var color: Color {
        switch self {
        case .nominal: return .green
        case .fair: return .yellow
        case .serious: return .orange
        case .critical: return .red
        }
    }
}

public struct SystemHealthStats: Sendable {
    public var load1m: Double = 0.0
    public var load5m: Double = 0.0
    public var load15m: Double = 0.0
    public var uptimeFormatted: String = ""
    public var thermalState: ThermalStateLabel = .nominal
    public var wifiRSSI: Int = 0
    public var wifiBars: Int = 0
    public var hasWiFi: Bool = false
    
    public init(load1m: Double = 0.0, load5m: Double = 0.0, load15m: Double = 0.0, uptimeFormatted: String = "", thermalState: ThermalStateLabel = .nominal, wifiRSSI: Int = 0, wifiBars: Int = 0, hasWiFi: Bool = false) {
        self.load1m = load1m
        self.load5m = load5m
        self.load15m = load15m
        self.uptimeFormatted = uptimeFormatted
        self.thermalState = thermalState
        self.wifiRSSI = wifiRSSI
        self.wifiBars = wifiBars
        self.hasWiFi = hasWiFi
    }
}

public struct NetworkStats: Sendable {
    public var downloadBytesPerSec: Double = 0.0
    public var uploadBytesPerSec: Double = 0.0
    
    public var downloadFormatted: String {
        NetworkStats.formatRate(downloadBytesPerSec)
    }
    
    public var uploadFormatted: String {
        NetworkStats.formatRate(uploadBytesPerSec)
    }
    
    public static func formatRate(_ bytesPerSec: Double) -> String {
        if bytesPerSec >= 1024 * 1024 {
            return String(format: "%.1f MB/s", bytesPerSec / (1024 * 1024))
        } else if bytesPerSec >= 1024 {
            return String(format: "%.0f KB/s", bytesPerSec / 1024)
        } else {
            return String(format: "%.0f B/s", bytesPerSec)
        }
    }
    
    public init(downloadBytesPerSec: Double = 0.0, uploadBytesPerSec: Double = 0.0) {
        self.downloadBytesPerSec = downloadBytesPerSec
        self.uploadBytesPerSec = uploadBytesPerSec
    }
}

public struct DiskStats: Sendable {
    public var totalBytes: Int64 = 0
    public var freeBytes: Int64 = 0
    public var usedBytes: Int64 = 0
    public var usedPercent: Double = 0.0
    
    public var freeFormatted: String {
        ByteCountFormatter.string(fromByteCount: freeBytes, countStyle: .file)
    }
    
    public var totalFormatted: String {
        ByteCountFormatter.string(fromByteCount: totalBytes, countStyle: .file)
    }
    
    public init(totalBytes: Int64 = 0, freeBytes: Int64 = 0, usedBytes: Int64 = 0, usedPercent: Double = 0.0) {
        self.totalBytes = totalBytes
        self.freeBytes = freeBytes
        self.usedBytes = usedBytes
        self.usedPercent = usedPercent
    }
}

public struct BatteryStats: Sendable {
    public var hasBattery: Bool = false
    public var levelPercent: Int = 0
    public var isCharging: Bool = false
    public var isPluggedIn: Bool = false
    
    public init(hasBattery: Bool = false, levelPercent: Int = 0, isCharging: Bool = false, isPluggedIn: Bool = false) {
        self.hasBattery = hasBattery
        self.levelPercent = levelPercent
        self.isCharging = isCharging
        self.isPluggedIn = isPluggedIn
    }
}
