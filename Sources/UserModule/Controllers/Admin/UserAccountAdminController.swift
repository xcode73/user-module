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
    
    func listNavigation(_ req: Request) -> [LinkContext] {
        [
            LinkContext(label: "Create",
                        path: "create",
                        permission: ApiModel.permission(for: .create).key),
            
            LinkContext(label: "Invite",
                        path: "invitation",
                        permission: ApiModel.permission(for: .create).key),
        ]
    }
    
    
    private func render(_ req: Request, form: UserInvitationForm) -> Response {
        let ctx = UserInvitationContext(title: "Invite ",
                                        message: "inv",
                                        link: .init(label: ""),
                                        form: form.context(req))
        let template = UserInvitationAdminTemplate(ctx)
        return req.templates.renderHtml(template)
    }
    
    func invitationView(_ req: Request) async throws -> Response {
        // TODO: check permission
        let form = UserInvitationForm()
        form.fields = form.createFields(req)
        try await form.load(req: req)
        return render(req, form: form)
    }
    
    func invitationAction(_ req: Request) async throws -> Response {
        // TODO: check permission
        let form = UserInvitationForm()
        form.fields = form.createFields(req)
        try await form.load(req: req)
        try await form.process(req: req)
        guard try await form.validate(req: req) else {
            return render(req, form: form)
        }
        try await form.write(req: req)

        /// drop previous invitation
        try await UserInvitationModel.query(on: req.db).filter(\.$email == form.email).delete()
        // sliding expiration token...
        let expiration = Date().addingTimeInterval(86_400 * 7) // 1 week

        let model = UserInvitationModel(email: form.email, value: .generateToken(), expiration: expiration)
        try await model.create(on: req.db)
        
        var baseUrl = req.feather.publicUrl + "/"
//        if isApi, let scheme = try await req.system.variable.find("systemDeepLinkScheme")?.value {
//            baseUrl = scheme + "://"
//        }

        let html = """
            <h1>\(model.email)</h1>
            <p>\(model.value)</p>
            <a href="\(baseUrl)register/?invitation=\(model.value)&redirect=/login/">Create account</a>
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
