//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 02. 28..
//

import Vapor
import Feather

final class UserNewPasswordForm: AbstractForm {

    var password: String = ""

    init() {
        super.init()
        self.submit = "New password"
    }

    @FormFieldBuilder
    override func createFields(_ req: Request) -> [FormField] {
        InputField("password")
            .config {
                $0.output.context.type = .password
            }
            .validators {
                FormFieldValidator.required($1)
            }
            .write { [unowned self] in password = $1.input }
    }
}
