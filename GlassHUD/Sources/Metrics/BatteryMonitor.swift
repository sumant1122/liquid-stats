import Foundation
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
        
        return BatteryStats(
            hasBattery: true,
            levelPercent: percent,
            isCharging: isCharging,
            isPluggedIn: isPluggedIn
        )
    }
}
