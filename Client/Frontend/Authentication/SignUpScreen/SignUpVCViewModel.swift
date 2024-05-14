// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

protocol SignUpVCViewModelDelegate: AnyObject {
}

class SignUpVCViewModel {
    weak var delegate: SignUpVCViewModelDelegate?
    
    let isOnboarding: Bool
    
    init(isOnboarding: Bool) {
        self.isOnboarding = isOnboarding
    }
    
    func registerUser(parentVC: UIViewController,
                      firstName: String,
                      lastName: String,
                      email: String,
                      password: String,
                      completion: ((CustomError?) -> Void)?) {
        AppSessionManager.shared.performRegisterFreespokeUser(firstName: firstName,
                                                              lastName: lastName,
                                                              email: email,
                                                              password: password,
                                                              completion: { authResponse, error in
            if authResponse != nil {
                if let link = authResponse?.magicLink?.link, let linkURL = URL(string: link) {
                    AppSessionManager.shared.performAutoLogin(parentVC: parentVC,
                                                              linkURL: linkURL,
                                                              successCompletion: {
                        completion?(nil)
                    },
                                                              failureCompletion: { error in
                        completion?(nil)
                    })
                } else {
                    completion?(nil)
                }
            } else {
                completion?(error ?? CustomError.somethingWentWrong)
            }
        })
    }
    
    func authWithApple(completion: ((CustomError?) -> Void)?) {
        AppSessionManager.shared.performSignInWithApple(successCompletion: { authModel in
            completion?(nil)
        },
                                                        failureCompletion: { error in
            completion?((error as? CustomError) ?? CustomError.somethingWentWrong)
        })
    }
}
