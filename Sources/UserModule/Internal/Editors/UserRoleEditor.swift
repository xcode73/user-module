//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2021. 12. 06..
//

import Vapor
import Feather
import Fluent
import UserObjects

struct UserRoleEditor: FeatherModelEditor {
    let model: UserRoleModel
    let form: AbstractForm

    init(model: UserRoleModel, form: AbstractForm) {
        self.model = model
        self.form = form
    }

    @FormFieldBuilder
    func createFields(_ req: Request) -> [FormField] {
        InputField("key")
            .config {
                $0.output.context.label.required = true
            }
            .validators {
                FormFieldValidator.required($1)
                FormFieldValidator($1, "Key must be unique") { req, field in
                    try await req.user.role.repository.isUnique(\.$key == field.input, User.Role.getIdParameter(req))
                }
            }
            .read { $1.output.context.value = model.key }
            .write { model.key = $1.input }
        
        InputField("name")
            .config {
                $0.output.context.label.required = true
            }
            .validators {
                FormFieldValidator.required($1)
            }
            .read { $1.output.context.value = model.name }
            .write { model.name = $1.input }
        
        TextareaField("notes")
            .read { $1.output.context.value = model.notes }
            .write { model.notes = $1.input }

        CheckboxBundleField("permissions")
            .load { req, field in
                field.output.context.options = try await req.system.permission.getOptionBundles()
            }
            .read { req, field in
                let pids = try await UserRolePermissionModel.query(on: req.db)
                    .field(\.$permissionId)
                    .filter(\.$roleId == model.uuid)
                    .all()
                field.output.context.values = pids.map { $0.permissionId.string }
            }
            .save { req, field in
                let values = field.input.compactMap(\.uuid)
                let rp = values.map { UserRolePermissionModel(roleId: model.uuid, permissionId: $0) }
                try await UserRolePermissionModel.query(on: req.db).field(\.$permissionId).filter(\.$roleId == model.uuid).delete()
                try await rp.create(on: req.db)
            }
    }
}
