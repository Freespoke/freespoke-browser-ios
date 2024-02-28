import Foundation

public typealias HTTPHeaders = [String: String]

public enum HTTPTask {
    case request
    
    case multipartRequest(data: Data,
                          additionHeaders: HTTPHeaders?)
    
    case requestParameters(bodyParameters: HTTPParameters?,
        bodyEncoding: ParameterEncoding,
        urlParameters: HTTPParameters?)
    
    case requestParametersAndHeaders(bodyParameters: HTTPParameters?,
        bodyEncoding: ParameterEncoding,
        urlParameters: HTTPParameters?,
        additionHeaders: HTTPHeaders?)
    
    // case download, upload...etc
}
