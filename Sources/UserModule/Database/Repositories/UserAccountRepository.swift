//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 02. 24..
//

import Vapor
import Fluent
import Feather

struct UserAccountRepository: FeatherModelRepository {
    typealias DatabaseModel = UserAccountModel

    public private(set) var req: Request
    
    init(_ req: Request) {
        self.req = req
    }
}

extension UserAccountRepository {

    func query(_ email: String) -> QueryBuilder<DatabaseModel> {
        query().filter(\.$email == email.lowercased())
    }
    
    func find(_ email: String) async throws -> DatabaseModel? {
        try await query(email).first()
    }

    func roleIds(_ accountId: UUID) async throws -> [UUID] {
        try await UserAccountRoleModel.query(on: req.db).filter(\.$accountId == accountId).all().map(\.roleId)
    }
    
    func update(roleIds: [UUID], accountId: UUID) async throws {
        try await UserAccountRoleModel.query(on: req.db).filter(\.$accountId == accountId).delete()
        try await roleIds.map { UserAccountRoleModel(accountId: accountId, roleId: $0) }.create(on: req.db)
    }
}
