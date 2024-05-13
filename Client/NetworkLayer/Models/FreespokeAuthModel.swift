// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

struct FreespokeAuthModel: Codable {
    let id: String
    let accessToken: String
    let refreshToken: String
    let magicLink: MagicLinkModel?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case accessToken = "accessToken"
        case refreshToken = "refreshToken"
        case magicLink = "magic_link"
    }
}

struct MagicLinkModel: Codable {
    let userId: String?
    let link: String?
    let sent: Bool?
    
    private enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case link = "link"
        case sent = "sent"
    }
}
