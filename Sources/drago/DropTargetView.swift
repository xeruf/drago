import AppKit
import DragoCore

/// Area that accepts drops and prints each dropped file path or URL on its own line.
final class DropTargetView: NSView {
    private let onDone: () -> Void
    private let label = NSTextField(labelWithString: "Drop files here")
    private var highlighted = false { didSet { needsDisplay = true } }

    init(options: Options, onDone: @escaping () -> Void) {
        self.onDone = onDone
        super.init(frame: .zero)
        registerForDraggedTypes([.fileURL, .URL, .string])
        label.textColor = .secondaryLabelColor
        label.alignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: 64),
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) { fatalError("not used") }

    override func draw(_ dirtyRect: NSRect) {
        let path = NSBezierPath(roundedRect: bounds.insetBy(dx: 2, dy: 2), xRadius: 8, yRadius: 8)
        path.lineWidth = 2
        path.setLineDash([6, 4], count: 2, phase: 0)
        (highlighted ? NSColor.controlAccentColor : NSColor.tertiaryLabelColor).setStroke()
        path.stroke()
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        highlighted = true
        return .copy
    }

    override func draggingExited(_ sender: NSDraggingInfo?) { highlighted = false }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        highlighted = false
        let board = sender.draggingPasteboard
        var lines: [String] = []
        if let urls = board.readObjects(forClasses: [NSURL.self], options: nil) as? [URL], !urls.isEmpty {
            lines = urls.map(describeDropped)
        } else if let strings = board.readObjects(forClasses: [NSString.self], options: nil) as? [String] {
            lines = strings
        }
        guard !lines.isEmpty else { return false }
        lines.forEach { print($0) }
        // why: defer so the drag source gets its "accepted" reply before we possibly terminate.
        DispatchQueue.main.async(execute: onDone)
        return true
    }
}
