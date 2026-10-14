import Foundation
import Darwin

public final class MemoryMonitor {
    private let totalPhysicalMemory: UInt64
    
    public init() {
        self.totalPhysicalMemory = ProcessInfo.processInfo.physicalMemory
    }
    
    public func sample() -> MemoryStats {
        var vmStats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)
        
        let kr = withUnsafeMutablePointer(to: &vmStats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }
        
        guard kr == KERN_SUCCESS else {
            return MemoryStats(totalBytes: totalPhysicalMemory)
        }
        
        let pageSize = UInt64(vm_kernel_page_size)
        let active = UInt64(vmStats.active_count) * pageSize
        let wired = UInt64(vmStats.wire_count) * pageSize
        let compressed = UInt64(vmStats.compressor_page_count) * pageSize
        let used = active + wired + compressed
        let free = totalPhysicalMemory > used ? (totalPhysicalMemory - used) : 0
        let percent = min(max((Double(used) / Double(totalPhysicalMemory)) * 100.0, 0.0), 100.0)
        
        return MemoryStats(
            usedBytes: used,
            totalBytes: totalPhysicalMemory,
            usedPercent: percent,
            freeBytes: free
        )
    }
}
