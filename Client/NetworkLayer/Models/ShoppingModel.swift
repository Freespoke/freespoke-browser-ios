// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

struct ShoppingCollectionModel: Codable {
    var collections: [ShoppingCoollectionItemModel]
}

struct ShoppingCoollectionItemModel: Codable {
    var id: String?
    var title: String?
    var url: String?
    var thumbnail: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case url = "url"
        case thumbnail = "thumbnail"
    }
}
