import Foundation

/// Command-line options, modelled on dragon's flags so scripts work across platforms.
public struct Options: Equatable {
    public var andExit = false
    public var all = false
    public var allCompact = false
    public var target = false
    public var keep = false
    public var printPath = false
    public var onTop = true
    public var iconOnly = false
    public var readStdin = false
    public var paths: [String] = []

    public init() {}
}

public enum Command: Equatable {
    case run(Options)
    case help
    case version
}

public struct UsageError: Error, Equatable, CustomStringConvertible {
    public let description: String
}

public let version = "0.1.0"

public let usage = """
    Usage: drago [OPTIONS] [FILE...]

    Open a small window to drag files out of the terminal into other apps,
    or (--target) receive files dropped onto it and print their paths.

    Options:
      -x, --and-exit      exit after the first successful drag or drop
      -a, --all           add an item that drags all files at once
      -A, --all-compact   show only the all-at-once item
      -t, --target        act as a drop target and print dropped paths/URLs
      -k, --keep          with --target: keep accepting drops (default exits after one)
      -p, --print-path    print the path of each dragged file to stdout
      -T, --on-top        keep the window above other windows (default)
      -N, --no-on-top     let other windows cover it
      -i, --icon-only     show only icons, no file names
      -I, --stdin         read additional paths from stdin, one per line
      -h, --help          show this help
      -V, --version       show the version

    Without FILE arguments and without --stdin, --target is implied.
    """

/// Parses arguments (without the program name). Combined short flags like `-xa` are supported;
/// everything after `--` is treated as a path.
public func parse(_ args: [String]) throws -> Command {
    var o = Options()
    var onlyPaths = false
    for arg in args {
        if onlyPaths || arg == "-" || !arg.hasPrefix("-") {
            o.paths.append(arg)
            continue
        }
        if arg == "--" { onlyPaths = true; continue }
        let flags: [String]
        if arg.hasPrefix("--") {
            flags = [String(arg.dropFirst(2))]
        } else {
            flags = arg.dropFirst().map(String.init)
        }
        for flag in flags {
            switch flag {
            case "x", "and-exit": o.andExit = true
            case "a", "all": o.all = true
            case "A", "all-compact": o.allCompact = true
            case "t", "target": o.target = true
            case "k", "keep": o.keep = true
            case "p", "print-path": o.printPath = true
            case "T", "on-top": o.onTop = true
            case "N", "no-on-top": o.onTop = false
            case "i", "icon-only": o.iconOnly = true
            case "I", "stdin": o.readStdin = true
            case "h", "help": return .help
            case "V", "version": return .version
            default: throw UsageError(description: "unknown option: \(arg)")
            }
        }
    }
    if o.paths.isEmpty && !o.readStdin { o.target = true }
    return .run(o)
}

/// Resolves a user-supplied path against `cwd`, keeping URLs (scheme://) as they are.
public func resolve(_ path: String, cwd: String) -> URL {
    if let url = URL(string: path), let scheme = url.scheme, scheme.count > 1, path.contains("://") {
        return url
    }
    let expanded = (path as NSString).expandingTildeInPath
    let absolute = expanded.hasPrefix("/") ? expanded : (cwd as NSString).appendingPathComponent(expanded)
    return URL(fileURLWithPath: (absolute as NSString).standardizingPath)
}

/// How a dropped item is printed: file URLs as plain paths, everything else verbatim.
public func describeDropped(_ url: URL) -> String {
    url.isFileURL ? url.path : url.absoluteString
}
