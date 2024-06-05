// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

// MARK: - Story Feed Model
struct StoryFeedModel: Codable {
    var stories: [StoryFeedItemModel]?
}

// MARK: - Story Feed Item Model
struct StoryFeedItemModel: Codable {
    let articles: [StoryFeedArticleModel]?
    let tweets: [StoryFeedTweetModel]?
    let aiSummary: AISummary?
    let id: String?
    let name: String?
    let updatedAt: String?
    let hasAiSummary: Bool?
    let hasSeeMore: Bool?
    let category: StoryCategoryType?
    let links: StoryLinksModel?
    
    var updatedAtConverted: String? {
        if let updatedAt = self.updatedAt {
            let date = DateHelper.convertPublishedDateToReadableFormat(dateString: updatedAt)
            return date
        } else {
            return nil
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case articles = "articles"
        case tweets = "tweets"
        case aiSummary = "ai_summary"
        case id, name
        case updatedAt = "updated_at"
        case hasAiSummary = "has_ai_summary"
        case hasSeeMore = "has_see_more"
        case category = "category"
        case links = "links"
    }
}

struct StoryLinksModel: Codable {
    let seeMoreLink: String?
    let shareLink: String?
    
    enum CodingKeys: String, CodingKey {
        case seeMoreLink = "see_more"
        case shareLink = "share"
    }
}

struct StoryFeedTweetModel: Codable {
    let id: String?
    let author: StoryFeedTweetAuthorModel?
    let bias: BiasType?
    let datePublished: String?
    let text: String?
    let tweetId: String?
    let url: String?
    
    var datePublishedConverted: String? {
        if let datePublished = self.datePublished {
            let date = DateHelper.convertPublishedDateToReadableFormat(dateString: datePublished)
            return date
        } else {
            return nil
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case author
        case bias
        case datePublished
        case text
        case tweetId = "tweet_id"
        case url
    }
}

struct StoryFeedTweetAuthorModel: Codable {
    let name: String?
    let profileImageUrl: String?
    let username: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case profileImageUrl = "profile_image_url"
        case username
    }
}

// MARK: - Story Category Type
enum StoryCategoryType: String, Codable {
    case trending = "Trending"
    case world = "World"
    
    var title: String {
        switch self {
        case .trending:
            return "Trending Story".uppercased()
        case .world:
            return "World Story".uppercased()
        }
    }
}

// MARK: - Story Feed Article Model
struct StoryFeedArticleModel: Codable {
    let id: String?
    let bias: BiasType?
    let datePublished: String?
    let title: String?
    let images: [String]?
    let publisherIcon: String?
    let publisherName: String?
    let url: String?
    
    var datePublishedConverted: String? {
        if let datePublished = self.datePublished {
            let date = DateHelper.convertPublishedDateToReadableFormat(dateString: datePublished)
            return date
        } else {
            return nil
        }
    }
}

// MARK: - AISummary
struct AISummary: Codable {
    let htmlLinkified: String?
    
    enum CodingKeys: String, CodingKey {
        case htmlLinkified = "htmlLinkified"
    }
}
