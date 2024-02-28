// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

public struct FormDataUrlEncoded: ParameterEncoder {
    public func encode(urlRequest: inout URLRequest, with parameters: HTTPParameters) throws {
        do {
            guard let url = urlRequest.url else {
                throw NetworkError.missingURL
            }
            
            if var requestBodyComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
               !parameters.isEmpty {
                requestBodyComponents.queryItems = [URLQueryItem]()
                for (key, value) in parameters {
                    let queryItem = URLQueryItem(name: key,
                                                 value: "\(value)")
                    requestBodyComponents.queryItems?.append(queryItem)
                }
                urlRequest.httpBody = requestBodyComponents.query?.data(using: .utf8)
            }
        } catch {
            throw NetworkError.encodingFailed
        }
    }
}
