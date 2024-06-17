// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

// MARK: - BreakingNewsModel
struct BreakingNewsModel: Codable {
    let data: [Datum]
//    let total: Int
}

// MARK: - Datum
struct Datum: Codable {
    let id: String
    let type: DatumType?
    let article: BreakingNewsArticleModel?
    let tweet: BreakingNewsTweetModel?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case type
        case article
        case tweet
    }
}

enum DatumType: String, Codable {
    case article = "article"
    case tweet = "tweet"
}

// MARK: - Breaking News Article Model
struct BreakingNewsArticleModel: Codable {
    let url: String
    let articleID: String
    let fullInfo: FullInfoModel

    enum CodingKeys: String, CodingKey {
        case url
        case articleID = "article_id"
        case fullInfo = "full_info"
    }
}

// MARK: - FullInfoModel
struct FullInfoModel: Codable {
    let bias: BiasType?
    let headline: String?
    let url: String?
    let datePublished: String?
    let images: [String]?
    let publisherName: String?
    let publisherIcon: String?
    
    var datePublishedConverted: String? {
        if let datePublished = self.datePublished {
            let date = DateHelper.convertPublishedDateToReadableFormat(dateString: datePublished)
            return date
        } else {
            return nil
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case bias = "bias"
        case headline = "headline"
        case url = "url"
        case datePublished = "datePublished"
        case images = "images"
        case publisherName = "publisherName"
        case publisherIcon = "publisherIcon"
    }
    
    init(from decoder: Decoder) throws {
        let modelContainer = try decoder.container(keyedBy: CodingKeys.self)
        
        if let biasString = try? modelContainer.decode(String?.self, forKey: .bias),
            !biasString.isEmpty,
        let bias = BiasType(rawValue: biasString) {
            self.bias = bias
        } else {
            self.bias = nil
        }
        
        self.headline = try? modelContainer.decode(String?.self, forKey: .headline)
        self.url = try? modelContainer.decode(String?.self, forKey: .url)
        self.datePublished = try? modelContainer.decode(String?.self, forKey: .datePublished)
        self.images = try? modelContainer.decode([String]?.self, forKey: .images)
        self.publisherName = try? modelContainer.decode(String?.self, forKey: .publisherName)
        self.publisherIcon = try? modelContainer.decode(String?.self, forKey: .publisherIcon)
    }
}

// MARK: - BiasType
enum BiasType: String, Codable {
    case left = "left"
    case middle = "middle"
    case right = "right"
    
    var title: String {
        switch self {
        case .left:
            return "left".uppercased()
        case .middle:
            return "middle".uppercased()
        case .right:
            return "right".uppercased()
        }
    }
    
    var iconImage: UIImage? {
        switch self {
        case .left:
            return UIImage.templateImageNamed(ImageIdentifiers.imgBiasLeftIcon)
        case .middle:
            return nil
        case .right:
            return UIImage.templateImageNamed(ImageIdentifiers.imgBiasRightIcon)
        }
    }
}

// MARK: - BreakingNews TweetModel
struct BreakingNewsTweetModel: Codable {
    let url: String
    let datePublished: String?
    let tweetID: String
    let text: String?
    let author: Author?
    let bias: BiasType?
    
    var datePublishedConverted: String? {
        if let datePublished = self.datePublished {
            let date = DateHelper.convertPublishedDateToReadableFormat(dateString: datePublished)
            return date
        } else {
            return nil
        }
    }

    enum CodingKeys: String, CodingKey {
        case url
        case datePublished = "datePublished"
        case tweetID = "tweet_id"
        case text
        case author
        case bias
    }
}

// MARK: - Author
struct Author: Codable {
    let name: String?
    let profileImageURL: String?
    let username: String?
    let imageURL: String?

    enum CodingKeys: String, CodingKey {
        case name
        case profileImageURL = "profile_image_url"
        case username
        case imageURL = "image_url"
    }
}
