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

struct UserRoleAdminController: AdminController {
    typealias ApiModel = User.Role
    typealias DatabaseModel = UserRoleModel
    
    typealias CreateModelEditor = UserRoleEditor
    typealias UpdateModelEditor = UserRoleEditor
    
    func listQuery(_ req: Request, _ qb: QueryBuilder<UserRoleModel>) async throws -> QueryBuilder<UserRoleModel> {
        qb.filter(\.$key != "root")
    }
    
    var listConfig: ListConfiguration {
        .init(allowedOrders: [
            "name"
        ],
        defaultSort: .asc)
    }

    func listSearch(_ term: String) -> [ModelValueFilter<DatabaseModel>] {
        [
            \.$key ~~ term,
            \.$name ~~ term,
        ]
    }
    
    func listColumns() -> [ColumnContext] {
        [
            .init("name"),
        ]
    }
    
    func listCells(for model: DatabaseModel) -> [CellContext] {
        [
            .link(model.name, ApiModel.permission(for: .detail)),
        ]
    }
    
    func detailFields() -> [DetailField<DatabaseModel>] {
        [
            .init { model, _ in .init("id", model.uuid.string) },
            .init { model, _ in .init("key", model.key) },
            .init { model, _ in .init("name", model.name) },
            .init { model, _ in .init("notes", model.notes) },
            .init { model, req in
                let ids = try await req.user.role.repository.permissionIds(model.uuid)
                let models = try await req.system.permission.get(ids)
                let value = models.map(\.name).joined(separator: "\n")
                return .init("permissions", value)
            },
        ]
    }

    func detailFields(for model: UserRoleModel) -> [DetailContext] {
        []
    }
    
    func deleteInfo(_ model: DatabaseModel) -> String {
        model.name
    }
    
}
