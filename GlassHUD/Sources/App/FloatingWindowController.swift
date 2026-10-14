import Cocoa
import SwiftUI

public final class FloatingHUDWindow: NSWindow {
    override public var canBecomeKey: Bool { true }
    override public var canBecomeMain: Bool { true }
}

public final class FloatingWindowController: NSWindowController {
    public let monitor: SystemMonitor
    private var hostingView: NSHostingView<GlassHUDView>?
    
    public init(monitor: SystemMonitor) {
        self.monitor = monitor
        
        let initialContentRect = NSRect(x: 100, y: 100, width: 260, height: 380)
        let window = FloatingHUDWindow(
            contentRect: initialContentRect,
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        super.init(window: window)
        
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true
        window.level = .floating
        window.isMovableByWindowBackground = true
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        
        let hudView = GlassHUDView(monitor: monitor)
        let hosting = NSHostingView(rootView: hudView)
        self.hostingView = hosting
        
        window.contentView = hosting
        
        // Position window nicely near top-right of the main screen
        if let screen = NSScreen.main {
            let visibleFrame = screen.visibleFrame
            let xPos = visibleFrame.maxX - 280
            let yPos = visibleFrame.maxY - 440
            window.setFrameOrigin(NSPoint(x: xPos, y: yPos))
        }
        
        monitor.onPinChanged = { [weak window] isPinned in
            window?.level = isPinned ? .floating : .normal
        }
        
        monitor.onCloseRequested = {
            NSApp.terminate(nil)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
