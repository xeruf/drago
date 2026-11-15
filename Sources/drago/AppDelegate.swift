import AppKit
import DragoCore

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let options: Options
    private let urls: [URL]
    private var window: NSWindow!

    init(options: Options, urls: [URL]) {
        self.options = options
        self.urls = urls
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 2
        stack.edgeInsets = NSEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)

        if !urls.isEmpty {
            if options.all || options.allCompact {
                stack.addArrangedSubview(DragItemView(urls: urls, options: options, onDone: finishedDrag))
            }
            if !options.allCompact {
                for url in urls {
                    stack.addArrangedSubview(DragItemView(urls: [url], options: options, onDone: finishedDrag))
                }
            }
        }
        if options.target {
            stack.addArrangedSubview(DropTargetView(options: options, onDone: finishedDrop))
        }
        for view in stack.arrangedSubviews {
            view.widthAnchor.constraint(equalTo: stack.widthAnchor, constant: -12).isActive = true
        }

        let scroll = NSScrollView()
        scroll.hasVerticalScroller = true
        scroll.drawsBackground = false
        scroll.documentView = stack
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.widthAnchor.constraint(equalTo: scroll.contentView.widthAnchor).isActive = true

        let height = min(stack.fittingSize.height, 480)
        window = EscapableWindow(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: max(height, 60)),
            styleMask: [.titled, .closable, .resizable, .utilityWindow],
            backing: .buffered, defer: false)
        window.title = "drago"
        window.contentView = scroll
        // why: the window is used while another app is focused (dragging into it);
        // at normal level it vanishes behind the terminal as soon as that is clicked.
        window.level = options.onTop ? .floating : .normal
        window.collectionBehavior = [.moveToActiveSpace, .fullScreenAuxiliary]
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }

    private func finishedDrag() {
        if options.andExit { NSApp.terminate(nil) }
    }

    private func finishedDrop() {
        if options.andExit || !options.keep { NSApp.terminate(nil) }
    }
}

/// Closes on Escape, like dragon.
final class EscapableWindow: NSWindow {
    override func cancelOperation(_ sender: Any?) { close() }
}
