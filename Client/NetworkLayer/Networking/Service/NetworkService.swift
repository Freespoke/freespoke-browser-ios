import Foundation

public typealias NetworkRouterCompletion = (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void

protocol NetworkServiceProtocol: AnyObject {
    associatedtype EndPoint: EndPointType
    func request(_ route: EndPoint, isShouldLog: Bool, completion: @escaping NetworkRouterCompletion)
    func cancel()
}

final class NetworkService<EndPoint: EndPointType>: NetworkServiceProtocol {
    public var task: URLSessionTask?
    
    // MARK: - isShouldLog this variable handle printing request/response to console
    func request(_ route: EndPoint, isShouldLog: Bool = true, completion: @escaping NetworkRouterCompletion) {
        let session = URLSession.shared
        
        do {
            let request = try self.buildRequest(from: route)
            if isShouldLog {
                NetworkLogger.logRequest(request: request, options: LogOption.defaultOptions, printer: NativePrinter())
            }
            
            let startDateOfResponse = Date()
            task = session.dataTask(with: request, completionHandler: { data, response, error in
                let requestDurationTime = Date().timeIntervalSince(startDateOfResponse)
                if let response = response as? HTTPURLResponse {
                    if isShouldLog {
                        NetworkLogger.logResponse(request: request, data: data, response: response, error: error, requestDuration: requestDurationTime, options: LogOption.defaultOptions, printer: NativePrinter())
                    }
                }
                completion(data, response, error)
            })
        } catch {
            completion(nil, nil, error)
        }
        self.task?.resume()
    }
    
    func cancel() {
        self.task?.cancel()
    }
    
    fileprivate func buildRequest(from route: EndPoint) throws -> URLRequest {
        var request = URLRequest(url: route.baseURL.appendingPathComponent(route.path),
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 60.0)
        
        request.httpMethod = route.httpMethod.rawValue
        do {
            switch route.task {
            case .request:
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
            case .multipartRequest(let data, let additionalHeaders):
                let boundary = "Boundary-\(UUID().uuidString)"
                request.setValue("multipart/form-data; boundary=\(boundary)",
                                 forHTTPHeaderField: "Content-Type")
                if let additionalHeaders = additionalHeaders {
                    self.addAdditionalHeaders(additionalHeaders, request: &request)
                }
                
                request.httpBody = createBody(
                    parameters: [:],
                    boundary: boundary,
                    data: data,
                    mimeType: "image/jpg",
                    filename: "avatar.jpg"
                )
            case .requestParameters(let bodyParameters,
                                    let bodyEncoding,
                                    let urlParameters):
                
                try self.configureParameters(bodyParameters: bodyParameters,
                                             bodyEncoding: bodyEncoding,
                                             urlParameters: urlParameters,
                                             request: &request)
                
            case .requestParametersAndHeaders(let bodyParameters,
                                              let bodyEncoding,
                                              let urlParameters,
                                              let additionalHeaders):
                
                if let additionalHeaders = additionalHeaders {
                    self.addAdditionalHeaders(additionalHeaders, request: &request)
                }
                
                try self.configureParameters(bodyParameters: bodyParameters,
                                             bodyEncoding: bodyEncoding,
                                             urlParameters: urlParameters,
                                             request: &request)
            }
            return request
        } catch {
            throw error
        }
    }
    
    fileprivate func createBody(parameters: [String: String],
                                boundary: String,
                                data: Data,
                                mimeType: String,
                                filename: String) -> Data {
        let body = NSMutableData()
        
        let boundaryPrefix = "--\(boundary)\r\n"
        
        for (key, value) in parameters {
            body.appendString(boundaryPrefix)
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }
        
        body.appendString(boundaryPrefix)
        body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.appendString("\r\n")
        body.appendString("--".appending(boundary.appending("--")))
        
        return body as Data
    }
    
    fileprivate func configureParameters(bodyParameters: HTTPParameters?,
                                         bodyEncoding: ParameterEncoding,
                                         urlParameters: HTTPParameters?,
                                         request: inout URLRequest) throws {
        do {
            try bodyEncoding.encode(urlRequest: &request,
                                    bodyParameters: bodyParameters,
                                    urlParameters: urlParameters)
        } catch {
            throw error
        }
    }
    
    fileprivate func addAdditionalHeaders(_ additionalHeaders: HTTPHeaders?, request: inout URLRequest) {
        guard let headers = additionalHeaders else { return }
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
}
