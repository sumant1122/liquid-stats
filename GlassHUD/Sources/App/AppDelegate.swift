import Cocoa
import SwiftUI

public final class AppDelegate: NSObject, NSApplicationDelegate {
    private var windowController: FloatingWindowController?
    private var monitor: SystemMonitor?
    private var statusItem: NSStatusItem?
    
    public func applicationDidFinishLaunching(_ notification: Notification) {
        // Run as accessory application (no Dock icon, acts as floating overlay)
        NSApp.setActivationPolicy(.accessory)
        
        let monitor = SystemMonitor()
        self.monitor = monitor
        
        let controller = FloatingWindowController(monitor: monitor)
        self.windowController = controller
        
        controller.showWindow(nil)
        controller.window?.makeKeyAndOrderFront(nil)
        
        setupStatusItem()
    }
    
    private func setupStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = item.button {
            button.image = NSImage(systemSymbolName: "gauge.with.dots.needle.bottom.50percent", accessibilityDescription: "System Stats")
            button.action = #selector(toggleWindow)
            button.target = self
        }
        self.statusItem = item
    }
    
    @objc private func toggleWindow() {
        guard let window = windowController?.window else { return }
        if window.isVisible {
            window.orderOut(nil)
        } else {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    public func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}
