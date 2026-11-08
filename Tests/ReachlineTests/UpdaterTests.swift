import Foundation
import Testing
@testable import Reachline

struct UpdaterTests {
    private func json(tag: String, asset: String = "Reachline.zip", url: String? = nil) -> Data {
        let link = url ?? "https://api.github.com/repos/aca2328/Reachline/releases/assets/714642952"
        return Data("""
        {"tag_name":"\(tag)","draft":false,"assets":[{"name":"\(asset)","url":"\(link)"}]}
        """.utf8)
    }

    @Test func parsesCurrentRelease() {
        let release = Updater.parseRelease(json(tag: "v1.0.100"))
        #expect(release?.build == 100)
        #expect(release?.version == "v1.0.100")
        #expect(release?.downloadURL == "https://api.github.com/repos/aca2328/Reachline/releases/assets/714642952")
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
        #expect(Updater.parseRelease(json(tag: "v1.0.100", url: "https://api.github.com/repos/someone/Reachline/releases/assets/714642952")) == nil)
        #expect(Updater.parseRelease(json(tag: "v1.0.100", url: "https://api.github.com/repos/aca2328/Reachline/releases/assets/")) == nil)
        #expect(Updater.parseRelease(json(tag: "v1.0.100", url: "https://api.github.com/repos/aca2328/Reachline/releases/assets/7/../../x")) == nil)
    }

    @Test func rejectsInvalidJSON() {
        #expect(Updater.parseRelease(Data("not json".utf8)) == nil)
    }
}

struct LoginItemTests {
    @Test func offersOnlyFromApplicationsFolders() {
        let home = "/Users/me"
        func installed(_ path: String) -> Bool {
            LoginItem.isInstalled(URL(fileURLWithPath: path), home: home)
        }
        #expect(installed("/Applications/Reachline.app"))
        #expect(installed("/Users/me/Applications/Reachline.app"))
        #expect(!installed("/Users/me/GitHub/Reachline/.build/Reachline.app"))
        #expect(!installed("/Applications/Reachline"))
    }
}
