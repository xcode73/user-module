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
            .init { model, _ in .init("token", model.email) },
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
    
    func invitationView(_ req: Request) async throws -> Response {
        guard req.checkPermission("user.profile.invitation") else {
            throw Abort(.forbidden)
        }

        let form = UserInvitationForm()
        form.fields = form.createFields(req)
        try await form.load(req: req)
        return render(req, form: form)
    }
    
    func invitationAction(_ req: Request) async throws -> Response {
        guard req.checkPermission("user.profile.invitation") else {
            throw Abort(.forbidden)
        }
        let user = try req.getUserAccount()
        
        let form = UserInvitationForm()
        form.fields = form.createFields(req)
        try await form.load(req: req)
        try await form.process(req: req)
        guard try await form.validate(req: req) else {
            return render(req, form: form)
        }
        try await form.write(req: req)

        try await UserInvitationModel.query(on: req.db).filter(\.$email == form.email).delete()
        // sliding expiration token...
        let expiration = Date().addingTimeInterval(86_400 * 7) // 1 week

        let model = UserInvitationModel(email: form.email,
                                        token: .generateToken(),
                                        expiration: expiration,
                                        inviterId: user.id)
        try await model.create(on: req.db)
        
        var baseUrl = req.feather.publicUrl + "/"
//        if isApi, let scheme = try await req.system.variable.find("systemDeepLinkScheme")?.value {
//            baseUrl = scheme + "://"
//        }

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
        
        return req.redirect(to: "/admin/user/accounts/")
    }
    
    func setUpInvitationRoutes(_ routes: RoutesBuilder) {
        let routes = getBaseRoutes(routes)
        
        routes.get("invitation", use: invitationView)
        routes.post("invitation", use: invitationAction)
    }
}
