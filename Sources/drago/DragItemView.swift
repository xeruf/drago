import AppKit
import DragoCore

/// One row in the window: drags its URLs (one file, or all files at once) when pulled.
final class DragItemView: NSView, NSDraggingSource {
    private let urls: [URL]
    private let options: Options
    private let onDone: () -> Void
    private let icon: NSImage

    init(urls: [URL], options: Options, onDone: @escaping () -> Void) {
        self.urls = urls
        self.options = options
        self.onDone = onDone
        self.icon = urls.count == 1 && urls[0].isFileURL
            ? NSWorkspace.shared.icon(forFile: urls[0].path)
            : NSImage(named: NSImage.multipleDocumentsName) ?? NSImage()
        super.init(frame: .zero)

        let imageView = NSImageView(image: icon)
        imageView.imageScaling = .scaleProportionallyUpOrDown
        imageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 32).isActive = true

        let row = NSStackView(views: [imageView])
        row.orientation = .horizontal
        row.spacing = 8
        if !options.iconOnly {
            let label = NSTextField(labelWithString: title)
            label.lineBreakMode = .byTruncatingMiddle
            label.toolTip = urls.map(describeDropped).joined(separator: "\n")
            row.addArrangedSubview(label)
        }
        row.translatesAutoresizingMaskIntoConstraints = false
        addSubview(row)
        NSLayoutConstraint.activate([
            row.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            row.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -4),
            row.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            row.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),
        ])
    }

    required init?(coder: NSCoder) { fatalError("not used") }

    private var title: String {
        urls.count == 1
            ? (urls[0].isFileURL ? urls[0].lastPathComponent : urls[0].absoluteString)
            : "All \(urls.count) items"
    }

    // why: without this the first click only focuses the window instead of starting the drag.
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }

    override func mouseDragged(with event: NSEvent) {
        let items = urls.map { url -> NSDraggingItem in
            let item = NSDraggingItem(pasteboardWriter: url as NSURL)
            item.setDraggingFrame(NSRect(x: 4, y: 2, width: 32, height: 32), contents: icon)
            return item
        }
        beginDraggingSession(with: items, event: event, source: self)
    }

    func draggingSession(_ session: NSDraggingSession,
                         sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        context == .outsideApplication ? [.copy, .link, .generic] : []
    }

    func draggingSession(_ session: NSDraggingSession, endedAt screenPoint: NSPoint,
                         operation: NSDragOperation) {
        guard !operation.isEmpty else { return }
        if options.printPath {
            urls.forEach { print(describeDropped($0)) }
        }
        onDone()
    }
}
