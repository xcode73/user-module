//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 02. 28..
//

import Vapor
import Feather

final class UserResetPasswordForm: AbstractForm {

    var email: String = ""
    
    init() {
        super.init()
        self.submit = "Reset password"
    }

    @FormFieldBuilder
    override func createFields(_ req: Request) -> [FormField] {
        InputField("email")
            .config {
                $0.output.context.type = .email
            }
            .validators {
                FormFieldValidator.required($1)
                FormFieldValidator.email($1)
            }
            .write { [unowned self] in email = $1.input }
    }
}
