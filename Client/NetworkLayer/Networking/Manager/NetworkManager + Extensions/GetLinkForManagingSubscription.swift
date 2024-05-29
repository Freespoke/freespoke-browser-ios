// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

extension NetworkManager {
    // MARK: getLinkForManagingSubscription
    
    func getLinkForManagingSubscription(completion: @escaping (_ authModel: ManagingSubscriptionModel?, _ error: CustomError?) -> Void) {
        func performRequest() {
            let endpoint: EndPoint = .getLinkForManagingSubscription
            router.request(endpoint, completion: { [weak self] data, response, error in
                guard let self = self else { return }
                self.responseDataProcessingGeneric(data: data, response: response, error: error, isShouldRefreshToken: true, completion: { (responseModel: ManagingSubscriptionModel?, responseError, isShouldRepeatRequest)  in
                    guard !isShouldRepeatRequest else {
                        performRequest()
                        return
                    }
                    completion(responseModel, responseError)
                })
            })
        }
        performRequest()
    }
}
