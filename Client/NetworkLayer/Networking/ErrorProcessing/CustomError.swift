// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

public enum CustomError: LocalizedError, Equatable {
    case decodingError
    case network(name: String?, message: String)
    case somethingWentWrong
    case doNothing
    case authenticationError //401
    case noInternetConnection
    case unexpectedError(code: Int)
    case failedLogout
    
    public var errorName: String {
        switch self {
        case .decodingError:
            return "Error"
        case .network(let name, _):
            return name ?? "Error"
        case .noInternetConnection:
            return "Error"
        case .somethingWentWrong:
            return "Error"
        case .doNothing:
            return ""
        case .authenticationError:
            return ""
        case .unexpectedError:
            return ""
        case .failedLogout:
            return "Error"
        }
    }
    
    public var errorDescription: String? {
        switch self {
        case .decodingError:
            return "Decoding error."
        case .network(_, let message):
            return message
        case .noInternetConnection:
            return "Please connect to the internet"
        case .somethingWentWrong:
            return "Something went wrong"
        case .doNothing:
            return ""
        case .authenticationError:
            return ""
        case .unexpectedError(let code):
            return "Unexpected error. Code: \(code)"
        case .failedLogout:
            return "Unable to log out"
        }
    }
}
