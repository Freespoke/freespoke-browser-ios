// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Security

protocol ObjectSavable {
    static func setObject<Object>(_ object: Object, forKey: Keychain.KeychainKeys) throws where Object: Encodable
    static func getObject<Object>(forKey: Keychain.KeychainKeys, castTo type: Object.Type) throws -> Object where Object: Decodable
}

enum ObjectSavableError: String, LocalizedError {
    case unableToEncode = "Unable to encode object into data"
    case noValue = "No data object found for the given key"
    case unableToDecode = "Unable to decode object into given type"
    
    var errorDescription: String? {
        rawValue
    }
}

class Keychain {
    fileprivate static func save(key: String, data: Data) -> OSStatus {
        let query = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccount as String: key,
            kSecValueData as String: data ] as [String: Any]
        
        SecItemDelete(query as CFDictionary)
        
        return SecItemAdd(query as CFDictionary, nil)
    }
    
    fileprivate static func load(key: String) -> Data? {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ] as [String: Any]
        
        var dataTypeRef: AnyObject?
        
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == noErr {
            return dataTypeRef as! Data?
        } else {
            return nil
        }
    }
    
    fileprivate static func deleteDataFromKeychain(forKey key: String) -> Bool {
        let query: [NSString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status == errSecSuccess || status == errSecItemNotFound {
            return true
        } else {
            print("Keychain error: \(status)")
            return false
        }
    }
}

// MARK: - KEYS & Variables

extension Keychain {
    enum KeychainKeys: String {
        case authInfo
    }
    
    static var authInfo: FreespokeAuthModel? {
        get {
            try? getObject(forKey: .authInfo,
                           castTo: FreespokeAuthModel.self)
        }
        
        set {
            do {
                if newValue == nil {
                    _ = Keychain.deleteDataFromKeychain(forKey: Keychain.KeychainKeys.authInfo.rawValue)
                    NotificationCenter.default.post(name: Notification.Name.freespokeUserAuthChanged, object: nil, userInfo: nil)
                } else {
                    try setObject(newValue, forKey: .authInfo)
                    NotificationCenter.default.post(name: Notification.Name.freespokeUserAuthChanged, object: nil, userInfo: nil)
                }
                print("TEST: Keychain authInfo: ", newValue)
            } catch {
                print("Unable to save object to keychain")
            }
        }
    }
}

// MARK: - ObjectSavable

extension Keychain: ObjectSavable {
    static func setObject<Object>(_ object: Object, forKey: KeychainKeys) throws where Object: Encodable {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            _ = self.save(key: forKey.rawValue, data: data)
        } catch {
            throw ObjectSavableError.unableToEncode
        }
    }
    
    static func getObject<Object>(forKey: KeychainKeys, castTo type: Object.Type) throws -> Object where Object: Decodable {
        guard let data = self.load(key: forKey.rawValue) else { throw ObjectSavableError.noValue }
        let decoder = JSONDecoder()
        do {
            let object = try decoder.decode(type, from: data)
            return object
        } catch {
            throw ObjectSavableError.unableToDecode
        }
    }
}
