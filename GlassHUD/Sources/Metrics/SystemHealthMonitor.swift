import Foundation
import Darwin
import CoreWLAN

public final class SystemHealthMonitor {
    public init() {}
    
    public func sample() -> SystemHealthStats {
        // 1. Load Averages
        var loadavg = [Double](repeating: 0.0, count: 3)
        getloadavg(&loadavg, 3)
        
        // 2. Uptime
        let uptime = ProcessInfo.processInfo.systemUptime
        let days = Int(uptime) / 86400
        let hours = (Int(uptime) % 86400) / 3600
        let mins = (Int(uptime) % 3600) / 60
        
        let uptimeFormatted: String
        if days > 0 {
            uptimeFormatted = "\(days)d \(hours)h"
        } else if hours > 0 {
            uptimeFormatted = "\(hours)h \(mins)m"
        } else {
            uptimeFormatted = "\(mins)m"
        }
        
        // 3. Thermal State
        let thermal = ProcessInfo.processInfo.thermalState
        let thermalLabel: ThermalStateLabel
        switch thermal {
        case .nominal:
            thermalLabel = .nominal
        case .fair:
            thermalLabel = .fair
        case .serious:
            thermalLabel = .serious
        case .critical:
            thermalLabel = .critical
        @unknown default:
            thermalLabel = .nominal
        }
        
        // 4. Wi-Fi Signal (RSSI)
        var hasWiFi = false
        var rssi = 0
        var bars = 0
        
        if let iface = CWWiFiClient.shared().interface(), iface.powerOn() {
            hasWiFi = true
            rssi = iface.rssiValue()
            // Map RSSI (typically -100 to -30 dBm) to 1..4 bars
            if rssi >= -55 {
                bars = 4
            } else if rssi >= -70 {
                bars = 3
            } else if rssi >= -85 {
                bars = 2
            } else {
                bars = 1
            }
        }
        
        return SystemHealthStats(
            load1m: loadavg[0],
            load5m: loadavg[1],
            load15m: loadavg[2],
            uptimeFormatted: uptimeFormatted,
            thermalState: thermalLabel,
            wifiRSSI: rssi,
            wifiBars: bars,
            hasWiFi: hasWiFi
        )
    }
}
