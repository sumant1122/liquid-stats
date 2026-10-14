import Foundation
import Darwin

public final class NetworkMonitor {
    private var prevBytesIn: UInt64 = 0
    private var prevBytesOut: UInt64 = 0
    private var prevTime: Date = Date()
    private var hasPrev = false
    
    public init() {
        _ = sample()
    }
    
    public func sample() -> NetworkStats {
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else {
            return NetworkStats()
        }
        
        defer { freeifaddrs(firstAddr) }
        
        var totalIn: UInt64 = 0
        var totalOut: UInt64 = 0
        var ptr: UnsafeMutablePointer<ifaddrs>? = firstAddr
        
        while let current = ptr {
            let interface = current.pointee
            let name = String(cString: interface.ifa_name)
            let addrFamily = interface.ifa_addr.pointee.sa_family
            
            if addrFamily == UInt8(AF_LINK) {
                if let data = interface.ifa_data {
                    let networkData = data.assumingMemoryBound(to: if_data.self).pointee
                    // Ignore loopback interfaces
                    if !name.hasPrefix("lo") {
                        totalIn += UInt64(networkData.ifi_ibytes)
                        totalOut += UInt64(networkData.ifi_obytes)
                    }
                }
            }
            ptr = interface.ifa_next
        }
        
        let now = Date()
        guard hasPrev else {
            prevBytesIn = totalIn
            prevBytesOut = totalOut
            prevTime = now
            hasPrev = true
            return NetworkStats()
        }
        
        let timeElapsed = now.timeIntervalSince(prevTime)
        guard timeElapsed > 0.05 else {
            return NetworkStats()
        }
        
        let deltaIn = totalIn >= prevBytesIn ? Double(totalIn - prevBytesIn) : 0.0
        let deltaOut = totalOut >= prevBytesOut ? Double(totalOut - prevBytesOut) : 0.0
        
        prevBytesIn = totalIn
        prevBytesOut = totalOut
        prevTime = now
        
        let downRate = deltaIn / timeElapsed
        let upRate = deltaOut / timeElapsed
        
        return NetworkStats(downloadBytesPerSec: downRate, uploadBytesPerSec: upRate)
    }
}
