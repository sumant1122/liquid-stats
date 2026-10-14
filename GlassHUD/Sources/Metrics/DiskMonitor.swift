import Foundation

public final class DiskMonitor {
    public init() {}
    
    public func sample() -> DiskStats {
        guard let attrs = try? FileManager.default.attributesOfFileSystem(forPath: "/") else {
            return DiskStats()
        }
        
        let total = (attrs[.systemSize] as? NSNumber)?.int64Value ?? 0
        let free = (attrs[.systemFreeSize] as? NSNumber)?.int64Value ?? 0
        let used = total >= free ? (total - free) : 0
        let pct = total > 0 ? (Double(used) / Double(total)) * 100.0 : 0.0
        
        return DiskStats(
            totalBytes: total,
            freeBytes: free,
            usedBytes: used,
            usedPercent: pct
        )
    }
}
