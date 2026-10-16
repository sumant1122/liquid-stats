import Foundation
import IOKit
import IOKit.ps

public final class BatteryMonitor {
    public init() {}
    
    public func sample() -> BatteryStats {
        guard let blob = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let list = IOPSCopyPowerSourcesList(blob)?.takeRetainedValue() as? [CFTypeRef],
              let first = list.first,
              let desc = IOPSGetPowerSourceDescription(blob, first)?.takeUnretainedValue() as? [String: Any] else {
            return BatteryStats(hasBattery: false)
        }
        
        let current = desc[kIOPSCurrentCapacityKey] as? Int ?? 0
        let max = desc[kIOPSMaxCapacityKey] as? Int ?? 100
        let isCharging = desc[kIOPSIsChargingKey] as? Bool ?? false
        let powerSourceState = desc[kIOPSPowerSourceStateKey] as? String ?? ""
        let isPluggedIn = (powerSourceState == kIOPSACPowerValue)
        let percent = max > 0 ? Int((Double(current) / Double(max)) * 100.0) : current
        
        // Detailed hardware telemetry from AppleSmartBattery
        var cycleCount = 0
        var healthPct = 100.0
        var wattage = 0.0
        
        let matchDict = IOServiceMatching("AppleSmartBattery")
        var iterator: io_iterator_t = 0
        if IOServiceGetMatchingServices(kIOMainPortDefault, matchDict, &iterator) == kIOReturnSuccess {
            defer { IOObjectRelease(iterator) }
            let service = IOIteratorNext(iterator)
            if service != 0 {
                defer { IOObjectRelease(service) }
                var properties: Unmanaged<CFMutableDictionary>?
                if IORegistryEntryCreateCFProperties(service, &properties, kCFAllocatorDefault, 0) == kIOReturnSuccess,
                   let dict = properties?.takeRetainedValue() as? [String: Any] {
                    cycleCount = dict["CycleCount"] as? Int ?? 0
                    let voltage = dict["Voltage"] as? Int ?? 0 // mV
                    let amperage = dict["Amperage"] as? Int ?? 0 // mA
                    let designCap = dict["DesignCapacity"] as? Int ?? 0
                    let rawMaxCap = dict["AppleRawMaxCapacity"] as? Int ?? dict["MaxCapacity"] as? Int ?? 0
                    
                    if designCap > 0 && rawMaxCap > 0 {
                        healthPct = min((Double(rawMaxCap) / Double(designCap)) * 100.0, 100.0)
                    }
                    wattage = abs(Double(voltage) * Double(amperage)) / 1_000_000.0
                }
            }
        }
        
        return BatteryStats(
            hasBattery: true,
            levelPercent: percent,
            isCharging: isCharging,
            isPluggedIn: isPluggedIn,
            wattage: wattage,
            healthPercent: healthPct,
            cycleCount: cycleCount
        )
    }
}
