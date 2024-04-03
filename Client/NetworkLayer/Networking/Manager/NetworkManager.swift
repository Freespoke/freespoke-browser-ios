import Foundation
import AVFoundation

enum NetworkResult {
    case success
    case failure(CustomError)
}

final class NetworkManager: NetworkManagerProtocol {
    let router = NetworkService<EndPoint>()
    
    deinit {
#if DEBUG
        print("Was deinit -----> \(String(describing: type(of: self)))")
#endif
    }
    
    func handleNetworkResponse(data: Data?, response: URLResponse?, error: Error?) -> NetworkResult {
        if let response = response as? HTTPURLResponse {
            switch response.statusCode {
            case 200...299:
                return .success
            default:
                return .failure(ErrorProcessing.processError(data: data, response: response, error: error))
            }
        } else {
            return .failure(ErrorProcessing.processError(data: data, response: response, error: error))
        }
    }
    
    func responseDataProcessingGeneric<ResponseGenericModel: Decodable>(data: Data?, response: URLResponse?, error: Error?, isShouldRefreshToken: Bool, completion: @escaping(_ modelForMapping: ResponseGenericModel?, _ networkError: CustomError?, _ isShouldRepeatRequest: Bool) -> Void) {
        let result = self.handleNetworkResponse(data: data, response: response, error: error)
        switch result {
        case .success:
            // If that's an Empty Model Submitted - skip parsing. Just rely on Status Codes.
            guard ResponseGenericModel.self != EmptyModel.self else {
                completion(nil, nil, false)
                return
            }
            guard let responseData = data else {
                completion(nil, .somethingWentWrong, false)
                return
            }
            do {
                let apiResponse = try JSONDecoder().decode(ResponseGenericModel.self, from: responseData)
                completion(apiResponse, nil, false)
            } catch let error {
#if DEBUG
                print(error.localizedDescription)
#endif
                completion(nil, .somethingWentWrong, false)
            }
        case .failure(let networkFailureError):
                if isShouldRefreshToken && (networkFailureError == .authenticationError) {
                    AppSessionManager.shared.performRefreshFreespokeToken(completion: { apiAuthModel, error in
                        if error == nil {
                            completion(nil, nil, true)
                        } else {
                            print("Should perform force logout!!!")
                            AppSessionManager.shared.performFreespokeForceLogout(showAlert: true)
                        }
                    })
                } else {
                    completion(nil, networkFailureError, false)
                }
        }
    }
    
    func responseDataProcessingWithoutMapping(data: Data?, response: URLResponse?, error: Error?, completion: @escaping(_ data: Data?, _ networkError: CustomError?) -> Void) {
        let result = self.handleNetworkResponse(data: data, response: response, error: error)
        switch result {
        case .success:
            //            guard let data = data else {
            //                completion(nil, .somethingWentWrong)
            //                return
            //            }
            completion(data, nil)
        case .failure(let networkFailureError):
            completion(nil, networkFailureError)
        }
    }
}
