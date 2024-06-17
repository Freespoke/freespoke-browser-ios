// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

extension NetworkManager {
    // MARK: Get Advertisement
    
    func getAdvertisement(completion: @escaping (_ advertisementModel: AdvertisementModel?, _ error: CustomError?) -> Void) {
        func performRequest() {
            let endpoint: EndPoint = .getAdvertisement
            router.request(endpoint, completion: { [weak self] data, response, error in
                guard let self = self else { return }
                self.responseDataProcessingGeneric(data: data, response: response, error: error, isShouldRefreshToken: false, completion: { (responseModel: AdvertisementModel?, responseError, isShouldRepeatRequest) in
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
