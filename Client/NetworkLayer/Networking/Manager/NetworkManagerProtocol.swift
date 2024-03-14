import Foundation
import UIKit

protocol NetworkManagerProtocol: AnyObject {
    var router: NetworkService<EndPoint> { get }
    
    func registerFreespokeUser(firstName: String, lastName: String, email: String, password: String, completion: @escaping (_ authModel: FreespokeAuthModel?, _ error: CustomError?) -> Void)
}
