import Foundation
import Darwin

public final class CPUMonitor {
    private var prevCpuLoad = host_cpu_load_info()
    private var hasPrev = false
    private var history: [Double] = Array(repeating: 0.0, count: 24)
    
    public init() {
        _ = sample()
    }
    
    public func sample() -> CPUStats {
        var cpuInfo = host_cpu_load_info()
        var count = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info_data_t>.size / MemoryLayout<integer_t>.size)
        
        let kr = withUnsafeMutablePointer(to: &cpuInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &count)
            }
        }
        
        guard kr == KERN_SUCCESS else {
            return CPUStats(history: history)
        }
        
        guard hasPrev else {
            prevCpuLoad = cpuInfo
            hasPrev = true
            return CPUStats(history: history)
        }
        
        let userDelta = Double(cpuInfo.cpu_ticks.0 - prevCpuLoad.cpu_ticks.0)
        let sysDelta = Double(cpuInfo.cpu_ticks.1 - prevCpuLoad.cpu_ticks.1)
        let idleDelta = Double(cpuInfo.cpu_ticks.2 - prevCpuLoad.cpu_ticks.2)
        let niceDelta = Double(cpuInfo.cpu_ticks.3 - prevCpuLoad.cpu_ticks.3)
        prevCpuLoad = cpuInfo
        
        let total = userDelta + sysDelta + idleDelta + niceDelta
        guard total > 0 else {
            return CPUStats(history: history)
        }
        
        let userPct = (userDelta / total) * 100.0
        let sysPct = (sysDelta / total) * 100.0
        let idlePct = (idleDelta / total) * 100.0
        let usagePct = min(max(((userDelta + sysDelta + niceDelta) / total) * 100.0, 0.0), 100.0)
        
        history.append(usagePct)
        if history.count > 24 {
            history.removeFirst()
        }
        
        return CPUStats(
            usagePercent: usagePct,
            userPercent: userPct,
            systemPercent: sysPct,
            idlePercent: idlePct,
            history: history
        )
    }
}
