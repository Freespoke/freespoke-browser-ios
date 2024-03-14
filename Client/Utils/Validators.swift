// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

enum ValidationResult {
    case valid
    case invalid(errorMessage: String)
}

enum Validator {
    static func validateFirstName(_ firstName: String?) -> ValidationResult {
        guard let firstName = firstName, !firstName.isEmpty else {
            return .invalid(errorMessage: "First Name is required. Please use letters only.")
        }
        return .valid
    }
    
    static func validateLastName(_ lastName: String?) -> ValidationResult {
        guard let lastName = lastName, !lastName.isEmpty else {
            return .invalid(errorMessage: "Last Name is required. Please use letters only.")
        }
        return .valid
    }
    
/*    func validateEmailFormat() -> Bool {
        let pattern = "^[_A-Za-z0-9-+]+(\\.[_A-Za-z0-9-+]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*(\\.[A-Za-z‌​]{2,})$"
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: self.removingTrailingWhitespaces())
    }
 */
    
    static func validateEmail(_ email: String?) -> ValidationResult {
        guard var email = email, !email.isEmpty else {
            return .invalid(errorMessage: "The email is required.")
        }
        email = email.replacingOccurrences(of: " ", with: "")
        
//        let pattern = "[a-zA-Z0-9]{1,128}[a-zA-Z0-9!#$%&'*+-/=?^_`{|.]{1,128}\\@[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}(\\.[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25})+"
        let pattern = "^[_A-Za-z0-9-+]+(\\.[_A-Za-z0-9-+]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*(\\.[A-Za-z‌​]{2,})$"
        var regex: NSRegularExpression?
        do {
            regex = try NSRegularExpression(pattern: pattern, options: [])
        } catch {
            return .invalid(errorMessage: "Please enter email in correct format.")
        }
        
        let matches = regex!.matches(in: email,
                                     options: .withTransparentBounds,
                                     range: NSRange(email.startIndex..., in: email))
        return !matches.isEmpty ? .valid : .invalid(errorMessage: "Please enter email in correct format.")
    }
    
    static func validatePassword(_ password: String?) -> ValidationResult {
        guard let password = password, password.count >= 8 else {
            return .invalid(errorMessage: "Passwords must be at least 8 characters with 1 uppercase and 1 lowercase letter.")
        }
        // Check for at least one uppercase letter
        guard password.range(of: #"(?=.*[A-Z])"#, options: .regularExpression) != nil else {
            return .invalid(errorMessage: "Passwords must be at least 8 characters with 1 uppercase and 1 lowercase letter.")
        }
        // Check for at least one lowercase literal
        guard password.range(of: #"(?=.*[a-z])"#, options: .regularExpression) != nil else {
            return .invalid(errorMessage: "Passwords must be at least 8 characters with 1 uppercase and 1 lowercase letter.")
        }
        
        return .valid
    }
}
