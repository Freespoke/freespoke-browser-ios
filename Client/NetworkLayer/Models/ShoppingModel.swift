// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

struct ShoppingCollectionModel: Codable {
    var collections: [ShoppingCoollectionItemModel]
}

struct ShoppingCoollectionItemModel: Codable, Hashable {
    var id: String
    var title: String
    var url: String
    var thumbnail: String
    
    var hashValue: Int {
        return id.hashValue << 15 + title.hashValue
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case url = "url"
        case thumbnail = "thumbnail"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.url = (try? container.decode(String.self, forKey: .url)) ?? ""
        self.thumbnail = (try? container.decode(String.self, forKey: .thumbnail)) ?? ""
    }
}
