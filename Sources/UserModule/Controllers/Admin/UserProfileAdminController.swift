//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 03. 04..
//

import Vapor
import Feather
import FeatherApi
import UserApi

struct UserProfileAdminController: AdminDetailController, AdminUpdateController {
    
    typealias UpdateModelEditor = UserAccountEditor
    typealias ApiModel = User.Account
    typealias DatabaseModel = UserAccountModel
    
    func identifier(_ req: Request) throws -> UUID {
        guard let id = req.auth.get(FeatherUser.self)?.id else {
            throw Abort(.notFound)
        }
        return id
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
    
    func getBaseRoutes(_ routes: RoutesBuilder) -> RoutesBuilder {
        routes
            .grouped("user")
            .grouped("profile")
    }
    
    func setUpDetailRoutes(_ routes: RoutesBuilder) {
        let baseRoutes = getBaseRoutes(routes)

        baseRoutes.get(use: detailView)
    }
    
    func setUpUpdateRoutes(_ routes: RoutesBuilder) {
        let baseRoutes = getBaseRoutes(routes)

        baseRoutes.get(Self.updatePathComponent, use: updateView)
        baseRoutes.post(Self.updatePathComponent, use: updateAction)
    }
    
}
