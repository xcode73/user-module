//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 03. 25..
//

import Vapor
import Feather

final class UserInvitationForm: AbstractForm {

    var email: String = ""

    init() {
        super.init()
        self.submit = "Send invitation"
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
            .read { [unowned self] in $1.output.context.value = email }
            .write { [unowned self] in email = $1.input }
    }
}
