import Foundation

extension NetworkManager {
    // MARK: registerFreespokeUser
    
    func registerFreespokeUser(firstName: String, lastName: String, email: String, password: String, completion: @escaping (_ authModel: FreespokeAuthModel?, _ error: CustomError?) -> Void) {
        func performRequest() {
            let endpoint: EndPoint = .registerFreespokeUser(firstName: firstName, lastName: lastName, email: email, password: password)
            router.request(endpoint, completion: { [weak self] data, response, error in
                guard let sSelf = self else { return }
                sSelf.responseDataProcessingGeneric(data: data, response: response, error: error, isShouldRefreshToken: false, completion: { (responseModel: FreespokeAuthModel?, responseError, isShouldRepeatRequest)  in
                    guard !isShouldRepeatRequest else {
                        performRequest()
                        return
                    }
                    if let authResponse = responseModel {
                        Keychain.authInfo = authResponse
                    }
                    completion(responseModel, responseError)
                })
            })
        }
        performRequest()
    }
}
