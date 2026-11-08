import Foundation
import Testing
@testable import Reachline

struct TargetStoreTests {
    /// targets.json as written by released versions. Users' custom targets
    /// survive updates only if every later version still decodes this.
    private let savedFile = Data("""
    [
      {
        "host" : "192.0.2.1",
        "name" : "My router",
        "network" : "Home",
        "probe" : "ICMP_ECHO",
        "scope" : "LAN"
      },
      { "host" : "9.9.9.9", "name" : "Quad9", "network" : "Quad9", "probe" : "DNS_RECURSOR", "scope" : "Public" },
      { "host" : "198.41.0.4", "name" : "Root A", "network" : "Verisign", "probe" : "DNS_AUTH", "scope" : "Root" },
      { "host" : "example.com", "name" : "Example", "network" : "IANA", "probe" : "HTTPS_CONNECT", "scope" : "Web" },
      { "host" : "example.org", "name" : "Example GET", "network" : "IANA", "probe" : "HTTPS_GET", "scope" : "Web" }
    ]
    """.utf8)

    private let edited = [ProbeTarget(name: "Edited", host: "1.1.1.1", network: "Cloudflare", scope: "Public", probe: .icmpEcho)]

    @Test func decodesFilesFromReleasedVersions() throws {
        let targets = try JSONDecoder().decode([ProbeTarget].self, from: savedFile)
        #expect(targets.map(\.probe) == ProbeType.allCases)
        #expect(targets[0] == ProbeTarget(name: "My router", host: "192.0.2.1", network: "Home", scope: "LAN", probe: .icmpEcho))
    }

    @Test func savingKeepsUnreadableFileAside() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: dir) }
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let url = dir.appendingPathComponent("targets.json")
        let unreadable = Data(#"[{"name":"From a newer version","probe":"QUIC"}]"#.utf8)
        try unreadable.write(to: url)

        try TargetStore.save(edited, to: url)

        let files = try FileManager.default.contentsOfDirectory(atPath: dir.path)
        let backup = try #require(files.first { $0.hasPrefix("targets.unreadable-") })
        #expect(try Data(contentsOf: dir.appendingPathComponent(backup)) == unreadable)
        #expect(try JSONDecoder().decode([ProbeTarget].self, from: Data(contentsOf: url)) == edited)
    }

    @Test func savingOverReadableFileMakesNoBackup() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: dir) }
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let url = dir.appendingPathComponent("targets.json")
        try savedFile.write(to: url)

        try TargetStore.save(edited, to: url)

        #expect(try FileManager.default.contentsOfDirectory(atPath: dir.path) == ["targets.json"])
    }
}
