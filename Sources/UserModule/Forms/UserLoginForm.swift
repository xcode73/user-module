//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2021. 11. 26..
//

final class UserLoginForm: AbstractForm {

    var email: String = ""
    var password: String = ""

    init() {
        super.init()
        self.submit = "Sign in"
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

        InputField("password")
            .config {
                $0.output.context.type = .password
            }
            .validators {
                FormFieldValidator.required($1)
            }
            .read { [unowned self] in $1.output.context.value = password }
            .write { [unowned self] in password = $1.input }
    }
}
