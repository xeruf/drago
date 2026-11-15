import AppKit
import DragoCore

setvbuf(stdout, nil, _IOLBF, 0)

let command: Command
do {
    command = try parse(Array(CommandLine.arguments.dropFirst()))
} catch {
    FileHandle.standardError.write("drago: \(error)\n\n\(usage)\n".data(using: .utf8)!)
    exit(2)
}

var options: Options
switch command {
case .help: print(usage); exit(0)
case .version: print("drago \(DragoCore.version)"); exit(0)
case .run(let o): options = o
}

if options.readStdin {
    while let line = readLine() {
        if !line.isEmpty { options.paths.append(line) }
    }
}

let cwd = FileManager.default.currentDirectoryPath
var urls: [URL] = []
for path in options.paths {
    let url = resolve(path, cwd: cwd)
    if url.isFileURL && !FileManager.default.fileExists(atPath: url.path) {
        FileHandle.standardError.write("drago: no such file: \(path)\n".data(using: .utf8)!)
        continue
    }
    urls.append(url)
}
if urls.isEmpty && !options.target {
    exit(1)
}

let app = NSApplication.shared
let delegate = AppDelegate(options: options, urls: urls)
app.delegate = delegate
// why: accessory = no Dock icon / menu bar takeover, like a transient helper window.
app.setActivationPolicy(.accessory)
app.run()
