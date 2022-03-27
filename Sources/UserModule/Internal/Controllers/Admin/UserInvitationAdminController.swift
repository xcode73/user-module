//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 03. 27..
//

import Feather
import Fluent
import UserObjects
import Vapor

struct UserInvitationAdminController: AdminController {
    typealias ApiModel = User.Invitation
    typealias DatabaseModel = UserInvitationModel
    
    typealias CreateModelEditor = UserInvitationEditor
    typealias UpdateModelEditor = UserInvitationEditor

    var listConfig: ListConfiguration {
        .init(allowedOrders: [
            "email",
        ])
    }
    
    func listQuery(_ req: Request, _ qb: QueryBuilder<DatabaseModel>) async throws -> QueryBuilder<DatabaseModel> {
        let qb = DatabaseModel.query(on: req.db)
        let user = try req.getUserAccount()
        if user.level == .root {
            return qb
        }
        return qb.filter(\.$inviterId == user.id)
    }

    func listSearch(_ term: String) -> [ModelValueFilter<DatabaseModel>] {
        [
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
    
    func detailFields() -> [DetailField<DatabaseModel>] {
        [
            .init { model, _ in .init("id", model.uuid.string) },
            .init { model, _ in .init("email", model.email) },
            .init { model, _ in .init("token", model.token) },
            .init { model, _ in .init("expiration", model.expiration.description) },
        ]
    }

    func detailFields(for model: DatabaseModel) -> [DetailContext] {
        []
    }
    
    func deleteInfo(_ model: DatabaseModel) -> String {
        model.email
    }
    
    private func render(_ req: Request, form: UserInvitationForm) -> Response {
        let ctx = UserInvitationContext(title: "Invite user",
                                        message: "Enter an email address to invite a new user account",
                                        link: .init(label: ""),
                                        form: form.context(req))
        let template = UserInvitationAdminTemplate(ctx)
        return req.templates.renderHtml(template)
    }
    
    // MARK: - invitation
    
    func beforeCreate(_ req: Request, _ model: UserInvitationModel) async throws {
        try await UserInvitationModel.query(on: req.db).filter(\.$email == model.email).delete()
        
        model.token = .generateToken()
        model.expiration = Date().addingTimeInterval(86_400 * 7) // 1 week
        model.inviterId = try req.getUserAccount().id
    }
    
    func afterCreate(_ req: Request, _ model: UserInvitationModel) async throws {
        let baseUrl = req.feather.publicUrl + "/"
        let html = """
            <h1>\(model.email)</h1>
            <p>\(model.token)</p>
            <a href="\(baseUrl)register/?invitation=\(model.token)&redirect=/login/">Create account</a>
        """

        _ = try await req.mail.send(.init(from: "noreply@feathercms.com",
                                          to: [model.email],
                                          cc: ["mail.tib@gmail.com", "gurrka@gmail.com", "malacszem92@gmail.com"],
                                          subject: "Invitation",
                                          content: .init(value: html, type: .html)))
    }
}
