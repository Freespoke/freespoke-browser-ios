// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

extension NetworkManager {
    // MARK: Get Story Feed
    
    func getStoryFeed(page: Int, perPage: Int, completion: @escaping (_ storyFeedModel: StoryFeedModel?, _ error: CustomError?) -> Void) {
        func performRequest() {
            let endpoint: EndPoint = .getStoryFeed(page: page, perPage: perPage)
            router.request(endpoint, completion: { [weak self] data, response, error in
                guard let self = self else { return }
                self.responseDataProcessingGeneric(data: data, response: response, error: error, isShouldRefreshToken: false, completion: { (responseModel: StoryFeedModel?, responseError, isShouldRepeatRequest) in
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
