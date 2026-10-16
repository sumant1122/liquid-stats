import Foundation
import Darwin
import IOKit
import CoreWLAN

struct BenchResult {
    let name: String
    let avgMicroseconds: Double
    let minMicroseconds: Double
    let maxMicroseconds: Double
}

func measure(iterations: Int = 100, block: () -> Void) -> (avg: Double, min: Double, max: Double) {
    var times: [Double] = []
    times.reserveCapacity(iterations)
    
    // Warm-up
    for _ in 0..<5 { block() }
    
    for _ in 0..<iterations {
        let start = clock_gettime_nsec_np(CLOCK_UPTIME_RAW)
        block()
        let end = clock_gettime_nsec_np(CLOCK_UPTIME_RAW)
        times.append(Double(end - start) / 1_000.0) // microseconds
    }
    
    let avg = times.reduce(0, +) / Double(times.count)
    let minTime = times.min() ?? 0
    let maxTime = times.max() ?? 0
    return (avg, minTime, maxTime)
}

print("==========================================================")
print("  ⚡ LiquidStats Performance & Kernel API Benchmark")
print("==========================================================")
print("Measuring kernel trap latencies over 100 iterations...\n")

// 1. Mach CPU Ticks
let cpuBench = measure {
    var cpuInfo = host_cpu_load_info()
    var count = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info_data_t>.size / MemoryLayout<integer_t>.size)
    _ = withUnsafeMutablePointer(to: &cpuInfo) {
        $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
            host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &count)
        }
    }
}

// 2. GPU Utilization (IOAccelerator)
let gpuBench = measure {
    let matchDict = IOServiceMatching("IOAccelerator")
    var iterator: io_iterator_t = 0
    if IOServiceGetMatchingServices(kIOMainPortDefault, matchDict, &iterator) == kIOReturnSuccess {
        let service = IOIteratorNext(iterator)
        if service != 0 {
            var properties: Unmanaged<CFMutableDictionary>?
            _ = IORegistryEntryCreateCFProperties(service, &properties, kCFAllocatorDefault, 0)
            IOObjectRelease(service)
        }
        IOObjectRelease(iterator)
    }
}

// 3. Mach VM & Memory Pressure
let vmBench = measure {
    var vmStats = vm_statistics64()
    var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)
    _ = withUnsafeMutablePointer(to: &vmStats) {
        $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
            host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
        }
    }
    var pressureLevel: Int32 = 0
    var size = MemoryLayout<Int32>.size
    _ = sysctlbyname("kern.memorystatus_vm_pressure_level", &pressureLevel, &size, nil, 0)
}

// 4. BSD Network Interfaces (getifaddrs)
let netBench = measure {
    var ifaddr: UnsafeMutablePointer<ifaddrs>?
    if getifaddrs(&ifaddr) == 0, let first = ifaddr {
        var ptr: UnsafeMutablePointer<ifaddrs>? = first
        while let current = ptr {
            ptr = current.pointee.ifa_next
        }
        freeifaddrs(first)
    }
}

// 5. System Health (Load Average & Uptime)
let healthBench = measure {
    var loadavg = [Double](repeating: 0.0, count: 3)
    getloadavg(&loadavg, 3)
    _ = ProcessInfo.processInfo.systemUptime
    _ = ProcessInfo.processInfo.thermalState
}

// 6. libproc Process Scanning (all system PIDs)
let procBench = measure(iterations: 20) {
    var pids = [pid_t](repeating: 0, count: 2048)
    let bytesUsed = proc_listpids(UInt32(PROC_ALL_PIDS), 0, &pids, Int32(MemoryLayout<pid_t>.size * pids.count))
    let numPids = Int(bytesUsed) / MemoryLayout<pid_t>.size
    for i in 0..<numPids {
        let pid = pids[i]
        guard pid > 0 else { continue }
        var taskInfo = proc_taskinfo()
        _ = proc_pidinfo(pid, PROC_PIDTASKINFO, 0, &taskInfo, Int32(MemoryLayout<proc_taskinfo>.size))
    }
}

print(String(format: "%-30@ | %10@ | %10@ | %10@", "Kernel / Darwin Operation", "Avg Latency", "Min", "Max"))
print(String(repeating: "-", count: 68))
print(String(format: "%-30@ | %7.2f µs | %7.2f µs | %7.2f µs", "Mach CPU Load Info", cpuBench.avg, cpuBench.min, cpuBench.max))
print(String(format: "%-30@ | %7.2f µs | %7.2f µs | %7.2f µs", "IOAccelerator GPU Stats", gpuBench.avg, gpuBench.min, gpuBench.max))
print(String(format: "%-30@ | %7.2f µs | %7.2f µs | %7.2f µs", "Mach VM & Memory Pressure", vmBench.avg, vmBench.min, vmBench.max))
print(String(format: "%-30@ | %7.2f µs | %7.2f µs | %7.2f µs", "BSD Network (getifaddrs)", netBench.avg, netBench.min, netBench.max))
print(String(format: "%-30@ | %7.2f µs | %7.2f µs | %7.2f µs", "Load Avg & Thermal State", healthBench.avg, healthBench.min, healthBench.max))
print(String(format: "%-30@ | %7.2f ms | %7.2f ms | %7.2f ms", "libproc (All System PIDs)", procBench.avg / 1000.0, procBench.min / 1000.0, procBench.max / 1000.0))

print("\n" + String(repeating: "=", count: 68))
let totalKernelUs = cpuBench.avg + gpuBench.avg + vmBench.avg + netBench.avg + healthBench.avg
let totalTickMs = (totalKernelUs / 1000.0) + (procBench.avg / 1000.0)
print(String(format: "⚡ Total Core Metrics Sampling:  %.2f µs (%.3f ms)", totalKernelUs, totalKernelUs / 1000.0))
print(String(format: "⚡ Total Full Tick (incl. Procs): %.2f ms", totalTickMs))
print(String(format: "💤 Time Asleep Per 1s Cycle:     %.2f%% of the time", (1000.0 - totalTickMs) / 10.0))
print(String(repeating: "=", count: 68))

// Shell comparison
print("\nComparing with traditional subshell execution (fork + exec)...")
let shellStart = clock_gettime_nsec_np(CLOCK_UPTIME_RAW)
let task = Process()
task.executableURL = URL(fileURLWithPath: "/usr/bin/top")
task.arguments = ["-l", "1", "-n", "1"]
let pipe = Pipe()
task.standardOutput = pipe
try? task.run()
task.waitUntilExit()
let shellEnd = clock_gettime_nsec_np(CLOCK_UPTIME_RAW)
let shellMs = Double(shellEnd - shellStart) / 1_000_000.0

print(String(format: "• Subshell spawn ('/usr/bin/top'): %.2f ms", shellMs))
print(String(format: "• Direct Mach Core Metrics:        %.3f ms (%.0fx faster, 0 child processes)", totalKernelUs / 1000.0, (shellMs * 1000.0) / totalKernelUs))
print("==========================================================\n")
