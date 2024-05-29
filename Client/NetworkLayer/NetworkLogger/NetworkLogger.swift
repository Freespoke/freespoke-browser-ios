//  NetworkLogger.swift


import Foundation

private let nullString = "(null)"
private let separatorString = "*******************************"

public struct ResponseInfo {
    public var httpResponse: HTTPURLResponse?
    public var data: Data?
    public var error: Error?
    public var elapsedTime: TimeInterval
}

class NetworkLogger {
    // MARK: - Log request
    internal static func logRequest(request: URLRequest?, options: [LogOption], printer: Printer) {
        
        guard let request = request else {
            return
        }
        
        let method = request.httpMethod!
        let url = request.url?.absoluteString ?? nullString
        let headers = prettyPrintedString(from: request.allHTTPHeaderFields) ?? nullString
        
        // separator
        let openSeparator = options.contains(.includeSeparator) ? "\(separatorString)\n" : ""
        let closeSeparator = options.contains(.includeSeparator) ? "\n\(separatorString)" : ""
        
        let prettyPrint = options.contains(.jsonPrettyPrint)
        let body = string(from: request.httpBody, prettyPrint: prettyPrint) ?? nullString
        printer.print("\(openSeparator)[Request] \(method) '\(url)':\n\n[Headers]\n\(headers)\n\n[Body]\n\(body)\(closeSeparator)", phase: .request)
    }
    
    // MARK: - Log response
    internal static func logResponse(request: URLRequest?, data: Data?, response: HTTPURLResponse, error: Error?, requestDuration: TimeInterval, /*response: ResponseInfo,*/ options: [LogOption], printer: Printer) {
        
        let elapsedTime = requestDuration
        let error = error
        
        guard let request = request, let data = data else { return }
        
        // options
        let prettyPrint = options.contains(.jsonPrettyPrint)
        
        // request
        //        let requestMethod = request.httpMethod ?? nullString
        let requestUrl = request.url?.absoluteString ?? nullString
        
        // response
        let responseStatusCode = response.statusCode
        let responseHeaders = prettyPrintedString(from: response.allHeaderFields) ?? nullString
        let responseData = string(from: data, prettyPrint: prettyPrint) ?? nullString
        //        let elapsedTime = response
        
        // time
        let elapsedTimeString = String(format: "[%.4f s]", elapsedTime)
        
        // separator
        let openSeparator = options.contains(.includeSeparator) ? "\(separatorString)\n" : ""
        let closeSeparator = options.contains(.includeSeparator) ? "\n\(separatorString)" : ""
        
        // log
        let success = (error == nil)
        let responseTitle = success ? "Response" : "Response Error"
        
        printer.print("\(openSeparator)[\(responseTitle)] \(responseStatusCode) '\(requestUrl)' \(elapsedTimeString):\n\n[Headers]:\n\(responseHeaders)\n\n[Body]\n\(responseData)\(closeSeparator)", phase: .response(success: success))
    }
    
    // MARK: - Private helpers
    private static func string(from data: Data?, prettyPrint: Bool) -> String? {
        
        guard let data = data else {
            return nil
        }
        
        var response: String?
        
        if prettyPrint, let json = try? JSONSerialization.jsonObject(with: data, options: []), let prettyString = prettyPrintedString(from: json) {
            response = prettyString
        } else if let dataString = String.init(data: data, encoding: .utf8) {
            response = dataString
        }
        
        return response
    }
    
    private static func prettyPrintedString(from json: Any?) -> String? {
        guard let json = json else {
            return nil
        }
        
        var response: String?
        
        if let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
           let dataString = String.init(data: data, encoding: .utf8) {
            response = dataString
        }
        
        return response
    }
}
