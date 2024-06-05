// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Combine

class FreespokeHomepageViewModel {
    enum State: Equatable {
        case loading
        case loaded
        
        static func == (lhs: FreespokeHomepageViewModel.State, rhs: FreespokeHomepageViewModel.State) -> Bool {
            switch (lhs, rhs) {
            case (.loading, .loading):
                return true
            case (.loaded, .loaded):
                return true
            default:
                return false
            }
        }
    }
    
    private var networkManager: NetworkManagerProtocol = NetworkManager()
    
    var breakingNews: BreakingNewsModel?
    var storyFeed: StoryFeedModel?
    var advertisement: AdvertisementModel?
    var shoppingCollection: ShoppingCollectionModel?
    
    @Published var state: State = .loading
    
    init() {
        self.fetchAllData(completion: { [weak self] in
            self?.state = .loaded
        })
    }
    
    func refetchAllData(completion: (() -> Void)?) {
        self.state = .loading
        self.fetchAllData(completion: { [weak self] in
            self?.state = .loaded
            completion?()
        })
    }
    
    private func fetchAllData(completion: (() -> Void)?) {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        
        self.networkManager.getBreakingNews(page: 1,
                                            perPage: 10,
                                            completion: { [weak self] breakingNews, error in
            guard let self = self else { return }
            self.breakingNews = breakingNews
            dispatchGroup.leave()
        })
        
        dispatchGroup.enter()
        self.networkManager.getStoryFeed(page: 1,
                                         perPage: 4,
                                         completion: { [weak self] storyFeed, error in
            guard let self = self else { return }
            self.storyFeed = storyFeed
            dispatchGroup.leave()
        })
        
        dispatchGroup.enter()
        self.networkManager.getAdvertisement(completion: { [weak self] advertisement, error in
            guard let self = self else { return }
            self.advertisement = advertisement
            dispatchGroup.leave()
        })
        
        dispatchGroup.enter()
        self.networkManager.getShoppingCollection(page: 1,
                                                  perPage: 4,
                                                  completion: { [weak self] shoppingCollection, error in
            guard let self = self else { return }
            self.shoppingCollection = shoppingCollection
            dispatchGroup.leave()
        })
        
        dispatchGroup.notify(queue: .main) {
            completion?()
        }
    }
}
