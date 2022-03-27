//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2021. 11. 29..
//

import Vapor
import Feather
import UserObjects

struct UserAccountEditor: FeatherModelEditor {
    let model: UserAccountModel
    let form: AbstractForm

    init(model: UserAccountModel, form: AbstractForm) {
        self.model = model
        self.form = form
    }
    
    @FormFieldBuilder
    func createFields(_ req: Request) -> [FormField] {

        ImageField("image", path: "user/account")
            .read {
                if let key = model.imageKey {
                    $1.output.context.previewUrl = $0.fs.resolve(key: key)
                }
                ($1 as! ImageField).imageKey = model.imageKey
            }
            .write { model.imageKey = ($1 as! ImageField).imageKey }
                
        InputField("firstName")
            .config {
                $0.output.context.label.title = "First name"
            }
            .read { $1.output.context.value = model.firstName }
            .write { model.firstName = $1.input.emptyToNil }
        
        InputField("lastName")
            .config {
                $0.output.context.label.title = "Last name"
            }
            .read { $1.output.context.value = model.lastName }
            .write { model.lastName = $1.input.emptyToNil }
        
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

        InputField("password")
            .config {
                $0.output.context.type = .password
            }
            .write { req, field in
                if !field.input.isEmpty {
                    model.password = try Bcrypt.hash(field.input)
                }
            }

        CheckboxField("roles")
            .load { req, field in
                field.output.context.options = try await req.user.role.optionList()
            }
            .read { req, field in
                field.output.context.values = try await req.user.account.repository.roleIds(model.uuid).map(\.string)
            }
            .save { req, field in
                let values = field.input.compactMap(\.uuid)
                try await req.user.account.repository.update(roleIds: values, accountId: model.uuid)
            }
    }
}
