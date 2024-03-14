import Foundation

class ErrorProcessing: NSObject {
    static func processError(data: Data?, response: URLResponse?, error: Error?) -> CustomError {
        if let data = data, let response = response as? HTTPURLResponse {
            return ErrorProcessing.codeToErrorProcessed(code: response.statusCode, data: data)
        } else if let error = error as NSError? {
            return ErrorProcessing.codeToErrorProcessed(code: error.code, data: data)
        } else {
            return .somethingWentWrong
        }
    }
    
    internal static func codeToErrorProcessed(code: Int, data: Data?) -> CustomError {
            do {
                if let responseData = data {
                    let errorResponse = try JSONDecoder().decode(ResponseErrorModel.self, from: responseData)
                    return CustomError.network(name: errorResponse.name, message: errorResponse.message)
                }
            } catch {
                #if DEBUG
                print("TEST: codeToErrorProcessed error: ", error)
                #endif
            }
        switch code {
        case -999:
            return .doNothing
        case 401:
            return .authenticationError
        case NSURLErrorCannotConnectToHost: // Can not connect to the host
            return .unexpectedError(code: code)
        case NSURLErrorNotConnectedToInternet: // -1009
            return .noInternetConnection // No Internet connection
        case NSURLErrorCannotFindHost: // The connection failed because the host could not be found.//-1003
            return .unexpectedError(code: code)
        case -1001: // NSURLErrorTimedOut: // Request Timed Out.
            return .unexpectedError(code: code)
        default:
            return .unexpectedError(code: code)
        }
    }
}
