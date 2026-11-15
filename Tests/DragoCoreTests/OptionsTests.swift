import XCTest
@testable import DragoCore

final class OptionsTests: XCTestCase {
    private func opts(_ args: [String]) throws -> Options {
        guard case .run(let o) = try parse(args) else { XCTFail("expected run"); return Options() }
        return o
    }

    func testDragonStyleFlags() throws {
        let o = try opts(["-x", "-a", "file.pdf"])
        XCTAssertTrue(o.andExit)
        XCTAssertTrue(o.all)
        XCTAssertFalse(o.target)
        XCTAssertEqual(o.paths, ["file.pdf"])
    }

    func testCombinedShortFlagsAndLongFlags() throws {
        let o = try opts(["-xA", "--on-top", "a", "b"])
        XCTAssertTrue(o.andExit)
        XCTAssertTrue(o.allCompact)
        XCTAssertTrue(o.onTop)
        XCTAssertEqual(o.paths, ["a", "b"])
    }

    func testOnTopByDefault() throws {
        XCTAssertTrue(try opts(["a"]).onTop)
        XCTAssertFalse(try opts(["-N", "a"]).onTop)
    }

    func testNoPathsImpliesTarget() throws {
        XCTAssertTrue(try opts([]).target)
        XCTAssertFalse(try opts(["--stdin"]).target)
    }

    func testDoubleDashTreatsRestAsPaths() throws {
        XCTAssertEqual(try opts(["--", "-x", "--all"]).paths, ["-x", "--all"])
    }

    func testHelpVersionAndUnknown() {
        XCTAssertEqual(try parse(["-h"]), .help)
        XCTAssertEqual(try parse(["--version"]), .version)
        XCTAssertThrowsError(try parse(["-z"]))
    }

    func testResolve() {
        XCTAssertEqual(resolve("a/../b.txt", cwd: "/tmp/x").path, "/tmp/x/b.txt")
        XCTAssertEqual(resolve("/etc/hosts", cwd: "/tmp").path, "/etc/hosts")
        XCTAssertEqual(resolve("https://example.com/a", cwd: "/tmp").absoluteString, "https://example.com/a")
        XCTAssertTrue(resolve("~/x", cwd: "/tmp").path.hasPrefix(NSHomeDirectory()))
    }

    func testDescribeDropped() {
        XCTAssertEqual(describeDropped(URL(fileURLWithPath: "/a b/c")), "/a b/c")
        XCTAssertEqual(describeDropped(URL(string: "https://x.org/?q=1")!), "https://x.org/?q=1")
    }
}
