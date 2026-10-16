import Foundation
import IOKit

public final class GPUMonitor {
    private var history: [Double] = Array(repeating: 0.0, count: 20)
    
    public init() {}
    
    public func sample() -> GPUStats {
        let matchDict = IOServiceMatching("IOAccelerator")
        var iterator: io_iterator_t = 0
        guard IOServiceGetMatchingServices(kIOMainPortDefault, matchDict, &iterator) == kIOReturnSuccess else {
            return GPUStats(usagePercent: 0.0, history: history)
        }
        defer { IOObjectRelease(iterator) }
        
        var service = IOIteratorNext(iterator)
        var maxUtil: Double = 0.0
        
        while service != 0 {
            var properties: Unmanaged<CFMutableDictionary>?
            if IORegistryEntryCreateCFProperties(service, &properties, kCFAllocatorDefault, 0) == kIOReturnSuccess,
               let dict = properties?.takeRetainedValue() as? [String: Any],
               let perf = dict["PerformanceStatistics"] as? [String: Any] {
                
                if let util = perf["Device Utilization %"] as? Int {
                    maxUtil = max(maxUtil, Double(util))
                } else if let util = perf["Renderer Utilization %"] as? Int {
                    maxUtil = max(maxUtil, Double(util))
                }
            }
            IOObjectRelease(service)
            service = IOIteratorNext(iterator)
        }
        
        history.append(maxUtil)
        if history.count > 20 {
            history.removeFirst()
        }
        
        return GPUStats(usagePercent: maxUtil, history: history)
    }
}
