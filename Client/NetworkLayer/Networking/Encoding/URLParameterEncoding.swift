

import Foundation

public struct URLParameterEncoder: ParameterEncoder {
    public var urlEncodingType: UrlEncodingType
    public func encode(urlRequest: inout URLRequest, with parameters: HTTPParameters) throws {
        
        guard let url = urlRequest.url else { throw NetworkError.missingURL }
        
        if var urlComponents = URLComponents(url: url,
                                             resolvingAgainstBaseURL: false), !parameters.isEmpty {
            
            urlComponents.queryItems = [URLQueryItem]()
            
            for (key, value) in parameters {
                
                switch urlEncodingType {
                case .none:
                    let queryItem = URLQueryItem(name: key,
                                                 value: "\(value)")
                    urlComponents.queryItems?.append(queryItem)
                case .urlEncodingWithPercentEncoding:
                    let queryItem = URLQueryItem(name: key,
                                                 value: "\(value)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed))
                    urlComponents.queryItems?.append(queryItem)
                }
                
            }
            urlRequest.url = urlComponents.url
        }
        
        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        }
        
    }
}
