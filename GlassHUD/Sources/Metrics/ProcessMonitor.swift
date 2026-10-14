import Foundation
import Darwin

public final class ProcessMonitor {
    private struct PreviousSample {
        var totalTime: UInt64
        var name: String
    }
    
    private var previousSamples: [pid_t: PreviousSample] = [:]
    private var lastSampleTime: Date = Date()
    private var hasPrevious = false
    private let myPid = getpid()
    
    public init() {}
    
    public func sample() -> [ProcessItem] {
        var pids = [pid_t](repeating: 0, count: 2048)
        let bytesUsed = proc_listpids(UInt32(PROC_ALL_PIDS), 0, &pids, Int32(MemoryLayout<pid_t>.size * pids.count))
        let numPids = Int(bytesUsed) / MemoryLayout<pid_t>.size
        guard numPids > 0 else { return [] }
        
        let now = Date()
        var currentSamples: [pid_t: PreviousSample] = [:]
        currentSamples.reserveCapacity(numPids)
        
        for i in 0..<numPids {
            let pid = pids[i]
            guard pid > 0, pid != myPid else { continue }
            
            var taskInfo = proc_taskinfo()
            let taskInfoSize = Int32(MemoryLayout<proc_taskinfo>.size)
            let ret = proc_pidinfo(pid, PROC_PIDTASKINFO, 0, &taskInfo, taskInfoSize)
            guard ret == taskInfoSize else { continue }
            
            let totalTime = taskInfo.pti_total_user + taskInfo.pti_total_system
            
            // Look up cached name or query proc_name
            let name: String
            if let cached = previousSamples[pid] {
                name = cached.name
            } else {
                var nameBuffer = [CChar](repeating: 0, count: 256)
                proc_name(pid, &nameBuffer, UInt32(nameBuffer.count))
                let rawName = String(cString: nameBuffer).trimmingCharacters(in: .whitespacesAndNewlines)
                name = rawName.isEmpty ? "PID \(pid)" : rawName
            }
            
            currentSamples[pid] = PreviousSample(totalTime: totalTime, name: name)
        }
        
        guard hasPrevious else {
            previousSamples = currentSamples
            lastSampleTime = now
            hasPrevious = true
            return []
        }
        
        let intervalSec = now.timeIntervalSince(lastSampleTime)
        guard intervalSec > 0.2 else { return [] }
        let intervalNs = intervalSec * 1_000_000_000.0
        
        previousSamples = currentSamples
        lastSampleTime = now
        
        // Calculate CPU usage per process and aggregate by clean name
        var aggregated: [String: (pid: pid_t, cpuPercent: Double)] = [:]
        
        for (pid, current) in currentSamples {
            guard let prev = previousSamples[pid] else { continue }
            if current.totalTime >= prev.totalTime {
                let deltaNs = Double(current.totalTime - prev.totalTime)
                let percent = (deltaNs / intervalNs) * 100.0
                
                if percent >= 0.2 {
                    let cleanName = cleanProcessName(current.name)
                    if let existing = aggregated[cleanName] {
                        aggregated[cleanName] = (pid: existing.pid, cpuPercent: existing.cpuPercent + percent)
                    } else {
                        aggregated[cleanName] = (pid: pid, cpuPercent: percent)
                    }
                }
            }
        }
        
        var results = aggregated.map { name, val in
            ProcessItem(pid: val.pid, name: name, cpuPercent: val.cpuPercent)
        }
        
        results.sort { $0.cpuPercent > $1.cpuPercent }
        return Array(results.prefix(3))
    }
    
    private func cleanProcessName(_ raw: String) -> String {
        // Beautify helper process names
        var name = raw
        if name.hasSuffix(" Helper (Renderer)") {
            name = name.replacingOccurrences(of: " Helper (Renderer)", with: "")
        } else if name.hasSuffix(" Helper (GPU)") {
            name = name.replacingOccurrences(of: " Helper (GPU)", with: " GPU")
        } else if name.hasSuffix(" Helper") {
            name = name.replacingOccurrences(of: " Helper", with: "")
        }
        return name
    }
}
