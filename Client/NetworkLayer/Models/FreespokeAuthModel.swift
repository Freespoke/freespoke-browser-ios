// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

struct FreespokeAuthModel: Codable {
    let idToken: String?
    let user: UserModel?
    let accessToken: String
    let refreshToken: String
    let magicLink: MagicLinkModel?
    
    private enum CodingKeys: String, CodingKey {
        case idToken = "id_token"
        case user = "user"
        case accessToken = "accessToken"
        case refreshToken = "refreshToken"
        case magicLink = "magic_link"
    }
    
    init(idToken: String, accessToken: String, refreshToken: String, user: UserModel? = nil, magicLink: MagicLinkModel? = nil) {
        self.idToken = idToken
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.user = user
        self.magicLink = magicLink
    }
    
    init(from decoder: Decoder) throws {
        let modelContainer = try decoder.container(keyedBy: CodingKeys.self)
        
        self.idToken = try? modelContainer.decode(String?.self, forKey: .idToken)
        self.accessToken = try modelContainer.decode(String.self, forKey: .accessToken)
        self.refreshToken = try modelContainer.decode(String.self, forKey: .refreshToken)
        self.user = try? modelContainer.decode(UserModel?.self, forKey: .user)
        self.magicLink = try? modelContainer.decode(MagicLinkModel?.self, forKey: .magicLink)
    }
}

// MARK: UserModel

struct UserModel: Codable {
    let id: String?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
    }
    
    init(from decoder: Decoder) throws {
        let modelContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try? modelContainer.decode(String?.self, forKey: .id)
    }
}

// MARK: MagicLinkModel

struct MagicLinkModel: Codable {
    let userId: String?
    let link: String?
    let sent: Bool?
    
    private enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case link = "link"
        case sent = "sent"
    }
    
    init(from decoder: Decoder) throws {
        let modelContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try? modelContainer.decode(String?.self, forKey: .userId)
        self.link = try? modelContainer.decode(String?.self, forKey: .link)
        self.sent = try? modelContainer.decode(Bool?.self, forKey: .sent)
    }
}
