

import Foundation

extension Dictionary {
    
    func toModel<T: Codable>() -> T? {
        let decoder = JSONDecoder()
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: [])
            let model = try decoder.decode(T.self, from: data)
            return model
        } catch {
            print("Error: Could not decode model. \(error.localizedDescription)")
            return nil
        }
    }
    
}
