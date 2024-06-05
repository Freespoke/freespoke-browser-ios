import Foundation
import UIKit

protocol NetworkManagerProtocol: AnyObject {
    var router: NetworkService<EndPoint> { get }
    
    func registerFreespokeUser(firstName: String, lastName: String, email: String, password: String, completion: @escaping (_ authModel: FreespokeAuthModel?, _ error: CustomError?) -> Void)
    
    func getBreakingNews(page: Int, perPage: Int, completion: @escaping (_ breakingNewsModel: BreakingNewsModel?, _ error: CustomError?) -> Void)
    func getStoryFeed(page: Int, perPage: Int, completion: @escaping (_ storyFeedModel: StoryFeedModel?, _ error: CustomError?) -> Void)
    func getAdvertisement(completion: @escaping (_ advertisementModel: AdvertisementModel?, _ error: CustomError?) -> Void)
    func getShoppingCollection(page: Int, perPage: Int, completion: @escaping (_ shoppingCollectionModel: ShoppingCollectionModel?, _ error: CustomError?) -> Void)
}
