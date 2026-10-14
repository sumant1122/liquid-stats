import Foundation

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

public struct MemoryStats: Sendable {
    public var usedBytes: UInt64 = 0
    public var totalBytes: UInt64 = 0
    public var usedPercent: Double = 0.0
    public var freeBytes: UInt64 = 0
    
    public var usedFormatted: String {
        ByteCountFormatter.string(fromByteCount: Int64(usedBytes), countStyle: .memory)
    }
    
    public var totalFormatted: String {
        ByteCountFormatter.string(fromByteCount: Int64(totalBytes), countStyle: .memory)
    }
    
    public init(usedBytes: UInt64 = 0, totalBytes: UInt64 = 0, usedPercent: Double = 0.0, freeBytes: UInt64 = 0) {
        self.usedBytes = usedBytes
        self.totalBytes = totalBytes
        self.usedPercent = usedPercent
        self.freeBytes = freeBytes
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
