//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 03. 27..
//

import Vapor
import Feather
import UserObjects

struct UserInvitationEditor: FeatherModelEditor {
    let model: UserInvitationModel
    let form: AbstractForm

    init(model: UserInvitationModel, form: AbstractForm) {
        self.model = model
        self.form = form
    }
    
    @FormFieldBuilder
    func createFields(_ req: Request) -> [FormField] {
       
        InputField("email")
            .config {
                $0.output.context.type = .email
                $0.output.context.label.required = true
            }
            .validators {
                FormFieldValidator.required($1)
                FormFieldValidator.email($1)
            }
            .read { $1.output.context.value = model.email }
            .write { model.email = $1.input }
        
        InputField("token")
            .read { $1.output.context.value = model.token }
            .write { model.token = $1.input }
        
        InputField("expiration")
//            .read { $1.output.context.value = model.email }
//            .write { model.email = $1.input }

    }
}
