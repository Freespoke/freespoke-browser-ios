import Foundation

extension Encodable {
    public func toJSON() -> String? {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        
        do {
            let jsonData = try jsonEncoder.encode(self)
            let json = String(data: jsonData, encoding: String.Encoding.utf8) ?? ""
            return json
        } catch {
            return nil
        }
    }
    
    var dictionary: [String: Any] {
        return (try? JSONSerialization.jsonObject(with: JSONEncoder().encode(self))) as? [String: Any] ?? [:]
    }
    
    public func toJSON() -> NSString? {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        do {
            let jsonData = try jsonEncoder.encode(self)
            guard let object = try? JSONSerialization.jsonObject(with: jsonData, options: []),
                  let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
                  let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }
            return prettyPrintedString
        } catch {
            return nil
        }
    }
    
    static func fromDictionary<T: Codable>(_ dictionary: [String: Any]) -> T? {
        let decoder = JSONDecoder()
        do {
            let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
            let model = try decoder.decode(T.self, from: data)
            return model
        } catch {
            print("Error: Could not decode model. \(error.localizedDescription)")
            return nil
        }
    }
}
