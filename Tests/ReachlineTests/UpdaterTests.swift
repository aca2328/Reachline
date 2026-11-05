import Foundation
import Testing
@testable import Reachline

struct UpdaterTests {
    private func json(tag: String, asset: String = "Reachline.zip", url: String? = nil) -> Data {
        let link = url ?? "https://github.com/aca2328/Reachline/releases/download/\(tag)/\(asset)"
        return Data("""
        {"tag_name":"\(tag)","draft":false,"assets":[{"name":"\(asset)","browser_download_url":"\(link)"}]}
        """.utf8)
    }

    @Test func parsesCurrentRelease() {
        let release = Updater.parseRelease(json(tag: "v1.0.100"))
        #expect(release?.build == 100)
        #expect(release?.version == "v1.0.100")
    }

    @Test func rejectsReleaseWithOldAssetName() {
        #expect(Updater.parseRelease(json(tag: "v1.0.30", asset: "ReachabilityDashboard.zip")) == nil)
    }

    @Test func rejectsMalformedTags() {
        #expect(Updater.parseRelease(json(tag: "v2.0.5")) == nil)
        #expect(Updater.parseRelease(json(tag: "v1.0.abc")) == nil)
    }

    @Test func rejectsDownloadsFromElsewhere() {
        #expect(Updater.parseRelease(json(tag: "v1.0.100", url: "https://example.com/Reachline.zip")) == nil)
        #expect(Updater.parseRelease(json(tag: "v1.0.100", url: "https://github.com/someone/Reachline/releases/download/v1.0.100/Reachline.zip")) == nil)
    }

    @Test func rejectsInvalidJSON() {
        #expect(Updater.parseRelease(Data("not json".utf8)) == nil)
    }
}
