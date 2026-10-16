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
        
        let initialSize = NSSize(width: 290, height: 500)
        let screenFrame = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        let initialOrigin = NSPoint(
            x: screenFrame.maxX - initialSize.width - 20,
            y: screenFrame.maxY - initialSize.height - 20
        )
        
        let window = FloatingHUDWindow(
            contentRect: NSRect(origin: initialOrigin, size: initialSize),
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        super.init(window: window)
        
        window.isOpaque = false
        window.backgroundColor = .clear
        // Disable AppKit's rectangular window shadow so only SwiftUI's rounded continuous shadow is rendered
        window.hasShadow = false
        window.level = .floating
        window.isMovableByWindowBackground = true
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        
        let hudView = GlassHUDView(monitor: monitor)
        let hosting = NSHostingView(rootView: hudView)
        self.hostingView = hosting
        
        window.contentView = hosting
        
        monitor.onPinChanged = { [weak window] isPinned in
            window?.level = isPinned ? .floating : .normal
        }
        
        monitor.onModeChanged = { [weak self] isCompact in
            self?.updateWindowSize(isCompact: isCompact, animate: true)
        }
        
        monitor.onCloseRequested = {
            NSApp.terminate(nil)
        }
    }
    
    public func updateWindowSize(isCompact: Bool, animate: Bool) {
        guard let window = self.window else { return }
        let targetSize: NSSize = isCompact ? NSSize(width: 440, height: 72) : NSSize(width: 290, height: 505)
        
        var currentFrame = window.frame
        let deltaX = targetSize.width - currentFrame.size.width
        let deltaY = targetSize.height - currentFrame.size.height
        
        // Keep top-right corner stationary during transition
        currentFrame.origin.x -= deltaX
        currentFrame.origin.y -= deltaY
        currentFrame.size = targetSize
        
        window.setFrame(currentFrame, display: true, animate: animate)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
