import Foundation
import SwiftUI
import Combine

@MainActor
public final class SystemMonitor: ObservableObject {
    @Published public var cpu: CPUStats = CPUStats()
    @Published public var memory: MemoryStats = MemoryStats()
    @Published public var network: NetworkStats = NetworkStats()
    @Published public var disk: DiskStats = DiskStats()
    @Published public var battery: BatteryStats = BatteryStats()
    
    @Published public var refreshInterval: Double = 1.0 {
        didSet {
            restartTimer()
        }
    }
    
    @Published public var isCompactMode: Bool = false
    @Published public var isPinned: Bool = true {
        didSet {
            onPinChanged?(isPinned)
        }
    }
    
    public var onPinChanged: ((Bool) -> Void)?
    public var onCloseRequested: (() -> Void)?
    
    private let cpuMonitor = CPUMonitor()
    private let memoryMonitor = MemoryMonitor()
    private let networkMonitor = NetworkMonitor()
    private let diskMonitor = DiskMonitor()
    private let batteryMonitor = BatteryMonitor()
    
    private var timerTask: Task<Void, Never>?
    private var diskCounter = 0
    
    public init() {
        refreshAll()
        startTimer()
    }
    
    deinit {
        timerTask?.cancel()
    }
    
    public func refreshAll() {
        self.cpu = self.cpuMonitor.sample()
        self.memory = self.memoryMonitor.sample()
        self.network = self.networkMonitor.sample()
        self.battery = self.batteryMonitor.sample()
        
        // Disk stats don't change every second; refresh every 5 ticks to save IO
        if diskCounter % 5 == 0 {
            self.disk = self.diskMonitor.sample()
        }
        diskCounter += 1
    }
    
    private func startTimer() {
        timerTask?.cancel()
        let interval = self.refreshInterval
        
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
                guard !Task.isCancelled else { break }
                self?.refreshAll()
            }
        }
    }
    
    private func restartTimer() {
        startTimer()
    }
}
