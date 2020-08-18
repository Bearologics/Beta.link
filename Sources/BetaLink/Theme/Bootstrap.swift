import Foundation
import Publish
import Plot

public extension Theme {
    static var bootstrap: Self {
        Theme(
            htmlFactory: FoundationHTMLFactory()
        )
    }
}

private extension Item {
    var isApp: Bool {
        path.string.hasPrefix("apps/")
    }
}

private extension Node where Context == HTML.DocumentContext {
    static func head<T: Website>(
    for location: Location,
    on site: T) -> Node {
        head(for: location, on: site, stylesheetPaths: [
            "/css/styles.css"
        ])
    }
}

private extension Date {
    static var currentYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY"
        return formatter.string(from: Date())
    }
}

private struct FoundationHTMLFactory<Site: Website>: HTMLFactory {
    func makeIndexHTML(for index: Index,
                       context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: index, on: context.site),
            .body(
                .header(for: context, selectedSection: nil),
                .div(
                    .class("container"),
                    .contentBody(index.content.body),
                    .div(
                        .class("homepage-blog"),
                        .h5("Latest releases"),
                        .itemList(
                            for: context.allItems(
                                sortedBy: \.date,
                                order: .descending
                            ).filter { $0.isApp },
                            on: context.site
                        )
                    )
                ),
                .footer(for: context.site)
            )
        )
    }

    func makeSectionHTML(for section: Section<Site>,
                         context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: section, on: context.site),
            .body(
                .header(for: context, selectedSection: section.id),
                .div(
                    .class("container"),
                    .contentBody(section.body),
                    .itemList(for: section.items.filter { $0.isApp }, on: context.site)
                ),
                .footer(for: context.site)
            )
        )
    }

    func makeItemHTML(for item: Item<Site>,
                      context: PublishingContext<Site>) throws -> HTML {
        let metaData = item.metadata as? BetaLink.ItemMetadata
        return HTML(
            .lang(context.site.language),
            .head(for: item, on: context.site),
            .body(
                .header(for: context, selectedSection: item.sectionID),
                .div(
                    .h1(
                        .text(item.title)
                    ),
                    .class("container"),
                    .itemAuthorTags(for: item, on: context.site),
                    .embedly(url: metaData?.url ?? ""),
                    .contentBody(item.body)
                ),
                .footer(for: context.site)
            )
        )
    }

    func makePageHTML(for page: Page,
                      context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site),
            .body(
                .header(for: context, selectedSection: nil),
                .div(
                    .class("container"),
                    .contentBody(page.body)
                ),
                .footer(for: context.site)
            )
        )
    }

    func makeTagListHTML(for page: TagListPage,
                         context: PublishingContext<Site>) throws -> HTML? {
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site),
            .body(
                .header(for: context, selectedSection: nil),
                .div(
                    .class("container"),
                    .h1("Browse all ", .span(.class("font-commando"), .text("tags"))),
                    .ul(
                        .class("all-tags"),
                        .forEach(page.tags.sorted()) { tag in
                            .li(
                                .class("badge badge-tags"),
                                .a(
                                    .href(context.site.path(for: tag)),
                                    .text(tag.string)
                                )
                            )
                        }
                    )
                ),
                .footer(for: context.site)
            )
        )
    }

    func makeTagDetailsHTML(for page: TagDetailsPage,
                            context: PublishingContext<Site>) throws -> HTML? {
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site),
            .body(
                .header(for: context, selectedSection: nil),
                .div(
                    .class("container"),
                    .h1(
                        "Tagged with ",
                        .span(.class("tag"), .text(page.tag.string))
                    ),
                    .a(
                        .class("browse-all"),
                        .text("Browse all tags"),
                        .href(context.site.tagListPath)
                    ),
                    .itemList(
                        for: context.items(
                            taggedWith: page.tag,
                            sortedBy: \.date,
                            order: .descending
                        ),
                        on: context.site
                    )
                ),
                .footer(for: context.site)
            )
        )
    }
}

private extension Node where Context == HTML.BodyContext {
    static func wrapper(_ nodes: Node...) -> Node {
        .div(.class("wrapper"), .group(nodes))
    }

    static func header<T: Website>(
        for context: PublishingContext<T>,
        selectedSection: T.SectionID?
    ) -> Node {
        .header(
            .class("blog-header"),
            .nav(
                .class("navbar navbar-expand-md navbar-dark fixed-top"),
                .a(
                    .class("navbar-brand"),
                    .href("/"),
                    .text(context.site.name)
                ),
                .element(
                    named: "input",
                    attributes: [
                        .attribute(named: "aria-controls", value: "navbar-main"),
                        .id("navbar-toggle-cbox"),
                        .attribute(named: "role", value: "button"),
                        .attribute(named: "type", value: "checkbox")
                ]),
                .label(
                    .for("navbar-toggle-cbox"),
                    .class("navbar-toggler collapsed"),
                    .attribute(named: "data-toggle", value: "collapse"),
                    .attribute(named: "data-target", value: "#navbar"),
                    .attribute(named: "aria-expanded", value: "false"),
                    .attribute(named: "aria-controls", value: "navbar"),
                    .span(.class("navbar-toggler-icon"))
                ),
                .div(
                    .class("collapse navbar-collapse justify-content-between"),
                    .id("navbar"),
                    .ul(
                        .class("navbar-nav ml-auto"),
                        .group(
                            .li(
                                .class("nav-item\(selectedSection == nil ? " active": "")"),
                                .a(
                                    .class("nav-link"),
                                    .href("/"),
                                    .text("Home")
                                )
                            ),
                            .forEach(T.SectionID.allCases) { section in
                                .li(
                                    .class("nav-item\(section == selectedSection ? " active" : "")"),
                                    .a(
                                        .class("nav-link"),
                                        .href(context.sections[section].path),
                                        .text(context.sections[section].title)
                                    )
                                )
                            }
                        )
                    )
                )
            )
        )
    }
    
    static func itemList<T: Website>(for items: [Item<T>], on site: T) -> Node {
        return forEach(Array(items.filter({
            ($0.metadata as? BetaLink.ItemMetadata)?.visible ?? false
        })).chunked(into: 3)) { chunk in
            .div(.class("row"), forEach(chunk) { item in
                let metaData = item.metadata as? BetaLink.ItemMetadata
                return div(.class("col-sm-4"), article(
                    .class("card text-white bg-dark"),
                    .div(
                        .class("card-body"),
                        .h2(
                            .class("blog-post-title"),
                            .a(
                                .class("text-light"),
                                .href(item.path),
                                .text(item.title)
                            )
                        ),
                        .itemAuthorTags(for: item, on: site),
                        .embedly(url: metaData?.url ?? ""),
                        .p(.contentBody(item.body))
                    )
                ))
            })
        }
    }
    
    static func itemAuthorTags<T: Website>(for item: Item<T>, on site: T) -> Node {
        let metaData = item.metadata as? BetaLink.ItemMetadata
        return .group(
            .div(
                .class("blog-post-date text-secondary"),
                .element(named: "time", nodes: [
                    .attribute(named: "datetime", value: item.date.description),
                    .text(DateFormatter.mediumDateStyleFormatter.string(from: item.date))
                ]),
                .span(
                    .attribute(named: "rel", value: "author"),
                    .text(" by "),
                    {
                        if metaData?.authorUrl == nil {
                            return .text(metaData?.author ?? "")
                        } else {
                            return .a(.href(metaData?.authorUrl ?? ""), .text(metaData?.author ?? ""))
                        }
                    }()
                )
            ),
            .div(
                .class("blog-post-tags text-secondary"),
                .forEach(item.tags) { tag in
                    .p(
                        .class("badge badge-tags"),
                        .a(.href(site.path(for: tag)), .text(tag.string))
                    )
                }
            )
        )
    }

    static func tagList<T: Website>(for item: Item<T>, on site: T) -> Node {
        return .ul(.class("tag-list"), .forEach(item.tags) { tag in
            .li(.a(
                .href(site.path(for: tag)),
                .text(tag.string)
            ))
        })
    }

    static func footer<T: Website>(for site: T) -> Node {
        .footer(
            .script(
                .attribute(named: "aync"),
                .src("//cdn.embedly.com/widgets/platform.js"),
                .attribute(named: "charset", value: "UTF-8")
            ),
            .div(
                .class("text-center"),
                .style("vertical-align: bottom;"),
                .p(
                    .class("badge"),
                    .text("Made with ❤️ in Berlin by "),
                    .a(
                        .href("https://bearologics.com"),
                        .target(.blank),
                        .text("Bearologics UG (haftungsbeschränkt)")
                    ),
                    .text(" &bull; "),
                    .text("Generated using Swift. "),
                    .a(
                        .href("https://github.com/johnsundell/Publish"),
                        .target(.blank),
                        .text("Powered by Publish.")
                    )
                )
            )
        )
    }
    
    static func embedly(url: String) -> Node {
        .div(
            .blockquote(
                .class("embedly-card"),
                .attribute(named: "data-card-controls", value: "0"),
                .attribute(named: "data-card-theme", value: "dark"),
                .h4(.a(.href(url)))
            )
        )
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

private extension DateFormatter {
    static let mediumDateStyleFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}
