import Foundation
import Publish
import Plot
import SplashPublishPlugin

struct BetaLink: Website {
        enum SectionID: String, WebsiteSectionID {
            case apps
            case tags
            case legal
        }

        struct ItemMetadata: WebsiteItemMetadata {
            let author: String?
            let authorUrl: String?
            let url: String?
            let visible: Bool?
        }

        var url = URL(string: "https://beta.link")!
        var name = "Beta.link"
        var description = "We're happy to present you a curated list of TestFlight beta builds of our favourite iOS Apps. Feel free to check out some Apps and give some feedback to the developers using TestFlight Feedback."
        var language: Language { .english }
        var imagePath: Path? { nil }
    }

try BetaLink().publish(withTheme: .bootstrap, plugins: [
    .splash(withClassPrefix: "")
])
