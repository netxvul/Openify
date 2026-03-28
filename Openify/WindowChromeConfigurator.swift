import AppKit
import SwiftUI

struct WindowChromeConfigurator: NSViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            guard let window = view.window else { return }
            context.coordinator.bind(window: window)
            configure(window: window, coordinator: context.coordinator)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            guard let window = nsView.window else { return }
            context.coordinator.bind(window: window)
            configure(window: window, coordinator: context.coordinator)
        }
    }

    private func configure(window: NSWindow, coordinator: Coordinator) {
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.toolbarStyle = .unifiedCompact
        window.styleMask.insert(.fullSizeContentView)
        coordinator.repositionTrafficLights()
    }
}

extension WindowChromeConfigurator {
    final class Coordinator {
        private weak var window: NSWindow?
        private var observers: [NSObjectProtocol] = []

        func bind(window: NSWindow) {
            guard self.window !== window else { return }
            self.window = window
            installObservers(for: window)
            repositionTrafficLights()
        }

        private func installObservers(for window: NSWindow) {
            observers.forEach(NotificationCenter.default.removeObserver)
            observers.removeAll()

            let center = NotificationCenter.default
            observers.append(
                center.addObserver(
                    forName: NSWindow.didResizeNotification,
                    object: window,
                    queue: .main
                ) { [weak self] _ in
                    self?.repositionTrafficLights()
                }
            )
            observers.append(
                center.addObserver(
                    forName: NSWindow.didBecomeKeyNotification,
                    object: window,
                    queue: .main
                ) { [weak self] _ in
                    self?.repositionTrafficLights()
                }
            )
        }

        func repositionTrafficLights() {
            guard let window,
                let close = window.standardWindowButton(.closeButton),
                let mini = window.standardWindowButton(.miniaturizeButton),
                let zoom = window.standardWindowButton(.zoomButton),
                let superview = close.superview
            else { return }

            let leadingInset: CGFloat = 10
            let topInset: CGFloat = 10
            let spacing: CGFloat = 10
            let buttonSize = close.frame.size
            let y = superview.bounds.height - buttonSize.height - topInset

            close.setFrameOrigin(NSPoint(x: leadingInset, y: y))
            mini.setFrameOrigin(NSPoint(x: leadingInset + buttonSize.width + spacing, y: y))
            zoom.setFrameOrigin(
                NSPoint(x: leadingInset + (buttonSize.width + spacing) * 2, y: y)
            )
        }

        deinit {
            observers.forEach(NotificationCenter.default.removeObserver)
        }
    }
}
