//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2021. 11. 23..
//

import Feather
import Fluent
import UserObjects
import Vapor

struct UserAccountAdminController: AdminController {
    typealias ApiModel = User.Account
    typealias DatabaseModel = UserAccountModel
    
    typealias CreateModelEditor = UserAccountEditor
    typealias UpdateModelEditor = UserAccountEditor

    var listConfig: ListConfiguration {
        .init(allowedOrders: [
            "email",
            "last_access",
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
            .init("last_access", label: "Last access"),
        ]
    }
    
    func listCells(for model: DatabaseModel) -> [CellContext] {
        [
            .link(model.email, ApiModel.permission(for: .detail)),
            .link(model.formattedLastAccess, ApiModel.permission(for: .detail)),
        ]
    }
    
    func detailFields() -> [DetailField<UserAccountModel>] {
        [
            .init { model, _ in .init("id", model.uuid.string) },
            .init { model, _ in .init("image", model.imageKey, type: .image) },
            .init { model, _ in .init("firstName", model.firstName, label: "First name") },
            .init { model, _ in .init("lastName", model.lastName, label: "Last name") },
            .init { model, _ in .init("email", model.email) },
            .init { model, _ in .init("lastAccess", model.formattedLastAccess, label: "Last access") },
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
    
    func listNavigation(_ req: Request) -> [LinkContext] {
        [
            LinkContext(label: "Create",
                        path: "create",
                        permission: ApiModel.permission(for: .create).key),
            
            LinkContext(label: "Invite",
                        path: "invitation",
                        permission: "user.profile.invitation"),
        ]
    }
    
    
    private func render(_ req: Request, form: UserInvitationForm) -> Response {
        let ctx = UserInvitationContext(title: "Invite user",
                                        message: "Enter an email address to invite a new user account",
                                        link: .init(label: ""),
                                        form: form.context(req))
        let template = UserInvitationAdminTemplate(ctx)
        return req.templates.renderHtml(template)
    }
}
