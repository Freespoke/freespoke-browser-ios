

import Foundation

public typealias HTTPParameters = [String: Any]

public protocol ParameterEncoder {
    func encode(urlRequest: inout URLRequest, with parameters: HTTPParameters) throws
}

public enum UrlEncodingType {
    case urlEncodingWithPercentEncoding
    
    case none
}

public enum ParameterEncoding {
    
    case urlEncoding(urlEncodingType: UrlEncodingType)
    case jsonEncoding
    case urlAndJsonEncoding(urlEncodingType: UrlEncodingType)
    case formUrlencoded
    
    public func encode(urlRequest: inout URLRequest,
                       bodyParameters: HTTPParameters?,
                       urlParameters: HTTPParameters?) throws {
        do {
            switch self {
            case .urlEncoding(let urlEncodingType):
                guard let urlParameters = urlParameters else { return }
                
                try URLParameterEncoder(urlEncodingType: urlEncodingType).encode(urlRequest: &urlRequest, with: urlParameters)
                
            case .jsonEncoding:
                guard let bodyParameters = bodyParameters else { return }
                try JSONParameterEncoder().encode(urlRequest: &urlRequest, with: bodyParameters)
                
            case .urlAndJsonEncoding(let urlEncodingType):
                guard let bodyParameters = bodyParameters,
                    let urlParameters = urlParameters else { return }
                try URLParameterEncoder(urlEncodingType: urlEncodingType).encode(urlRequest: &urlRequest, with: urlParameters)
                try JSONParameterEncoder().encode(urlRequest: &urlRequest, with: bodyParameters)
            case .formUrlencoded:
                guard let bodyParameters = bodyParameters else { return }
                try FormDataUrlEncoded().encode(urlRequest: &urlRequest, with: bodyParameters)
            }
        } catch {
            throw error
        }
    }
}

public enum NetworkError: String, Error {
    case parametersNil = "Parameters were nil."
    case encodingFailed = "Parameter encoding failed."
    case missingURL = "URL is nil."
}
