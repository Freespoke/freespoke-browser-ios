// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

extension NetworkManager {
    // MARK: LogoutFreespokeUser
    
    func logoutFreespokeUser(completion: ((_ error: CustomError?) -> Void)?) {
        func performRequest() {
            let endpoint: EndPoint = .logoutFreespokeUser
            
            router.request(endpoint, completion: { [weak self] data, response, error in
                guard let sSelf = self else { return }
                sSelf.responseDataProcessingWithoutMapping(data: data, response: response, error: error, completion: { (_, responseError) in
                    completion?(responseError)
                })
            })
        }
        performRequest()
    }
}
