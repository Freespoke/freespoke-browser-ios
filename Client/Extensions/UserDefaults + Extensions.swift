// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

protocol UserDefaultsObjectSavable {
    func setObject<Object>(_ object: Object, forKey: UserDefaults.UserDefaultsKeys) throws where Object: Encodable
    func getObject<Object>(forKey: UserDefaults.UserDefaultsKeys, castTo type: Object.Type) throws -> Object where Object: Decodable
}

enum UserDefaultsObjectSavableError: String, LocalizedError {
    case unableToEncode = "Unable to encode object into data"
    case noValue = "No data object found for the given key"
    case unableToDecode = "Unable to decode object into given type"
    
    var errorDescription: String? {
        rawValue
    }
}

extension UserDefaults {
    enum UserDefaultsKeys: String {
        case easyListFileLatestUpdateDate
    }
    
    // MARK: - Variables
    
    var easyListFileLatestUpdateDate: Date? {
        get {
            object(forKey: UserDefaultsKeys.easyListFileLatestUpdateDate.rawValue) as? Date
        }
        set {
            if let newValue = newValue {
                save(newValue, forKey: .easyListFileLatestUpdateDate)
            } else {
                UserDefaults.standard.removeObject(
                    forKey: UserDefaults.UserDefaultsKeys.easyListFileLatestUpdateDate.rawValue
                )
            }
        }
    }
}

// MARK: - Helpers

extension UserDefaults {
    fileprivate func save(_ value: Any, forKey key: UserDefaultsKeys) {
        set(value, forKey: key.rawValue)
        synchronize()
    }
    
    fileprivate func data(forKey key: UserDefaultsKeys) -> Data? {
        data(forKey: key.rawValue)
    }
}

// MARK: - ObjectSavable

extension UserDefaults: UserDefaultsObjectSavable {
    func setObject<Object>(_ object: Object, forKey: UserDefaultsKeys) throws where Object: Encodable {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            set(data, forKey: forKey.rawValue)
        } catch {
            throw UserDefaultsObjectSavableError.unableToEncode
        }
    }
    
    func getObject<Object>(forKey: UserDefaultsKeys, castTo type: Object.Type) throws -> Object where Object: Decodable {
        guard let data = data(forKey: forKey) else { throw UserDefaultsObjectSavableError.noValue }
        let decoder = JSONDecoder()
        do {
            let object = try decoder.decode(type, from: data)
            return object
        } catch {
            throw UserDefaultsObjectSavableError.unableToDecode
        }
    }
}
