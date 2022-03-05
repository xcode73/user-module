//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2021. 11. 23..
//

import Feather
import Fluent
import UserApi

struct UserAccountAdminController: AdminController {
    typealias ApiModel = User.Account
    typealias DatabaseModel = UserAccountModel
    
    typealias CreateModelEditor = UserAccountEditor
    typealias UpdateModelEditor = UserAccountEditor

    var listConfig: ListConfiguration {
        .init(allowedOrders: [
            "email",
        ])
    }

    func listSearch(_ term: String) -> [ModelValueFilter<DatabaseModel>] {
        [
            \.$firstName ~~ term,
            \.$lastName ~~ term,
            \.$email ~~ term,
        ]
    }

    func listColumns() -> [ColumnContext] {
        [
            .init("email"),
        ]
    }
    
    func listCells(for model: DatabaseModel) -> [CellContext] {
        [
            .link(model.email, ApiModel.permission(for: .detail))
        ]
    }
    
    func detailFields() -> [DetailField<UserAccountModel>] {
        [
            .init { model, _ in .init("id", model.uuid.string) },
            .init { model, _ in .init("image", model.imageKey, type: .image) },
            .init { model, _ in .init("firstName", model.firstName, label: "First name") },
            .init { model, _ in .init("lastName", model.lastName, label: "Last name") },
            .init { model, _ in .init("email", model.email) },
            .init { model, req in
                let ids = try await req.user.account.repository.roleIds(model.uuid)
                let objects = try await req.user.role.repository.get(ids)
                let value = objects.map(\.name).joined(separator: "\n")
                return .init("roles", value)
            },
        ]
    }

    func detailFields(for model: DatabaseModel) -> [DetailContext] {
        []
    }
    
    func deleteInfo(_ model: DatabaseModel) -> String {
        model.email
    }
}
