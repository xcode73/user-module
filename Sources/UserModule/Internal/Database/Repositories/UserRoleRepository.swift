//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 02. 28..
//

import Feather
import Vapor
import Fluent
import FeatherObjects

struct UserRoleRepository: FeatherModelRepository {
    typealias DatabaseModel = UserRoleModel
    
    private(set) var req: Request
    
    init(_ req: Request) {
        self.req = req
    }
}

extension UserRoleRepository {
    
    func find(_ key: String) async throws -> DatabaseModel? {
        try await query().filter(\.$key == key).first()
    }
    
    func find(_ keys: [String]) async throws -> [DatabaseModel] {
        try await query().filter(\.$key ~~ keys).all()
    }
    
    func permissionIds(_ roleId: UUID) async throws -> [UUID] {
        try await UserRolePermissionModel.query(on: req.db).filter(\.$roleId == roleId).all().map(\.permissionId)
    }
    
    func findWithPermissions(_ key: String) async throws -> FeatherRole? {
        guard let role = try await find(key) else {
            return nil
        }
        let pids = try await UserRolePermissionModel.query(on: req.db).filter(\.$roleId == role.uuid).all().map(\.permissionId)
        let p = try await req.system.permission.get(pids).map {
            FeatherPermission.init(namespace: $0.namespace,
                                   context: $0.context,
                                   action: .init($0.action))
        }
        return FeatherRole(key: role.key, permissions: p)
    }

    func findWithPermissions(_ account: UUID) async throws -> [FeatherRole] {
        let rids = try await UserAccountRoleModel.query(on: req.db).filter(\.$accountId == account).all().map(\.roleId)
        var roles: [FeatherRole] = []
        for r in rids {
            guard let role = try await UserRoleModel.query(on: req.db).filter(\.$id == r).first() else {
                continue
            }
            let pids = try await UserRolePermissionModel.query(on: req.db).filter(\.$roleId == r).all().map(\.permissionId)
            let p = try await req.system.permission.get(pids).map {
                FeatherPermission.init(namespace: $0.namespace,
                                       context: $0.context,
                                       action: .init($0.action))
            }
            let r = FeatherRole(key: role.key, permissions: p)
            roles.append(r)
        }
        let authRole: FeatherRole? = try await req.invokeAllFirstAsync(.authenticatedRole)
        if let r = authRole {
            roles.append(r)
        }
        return roles
    }
}
