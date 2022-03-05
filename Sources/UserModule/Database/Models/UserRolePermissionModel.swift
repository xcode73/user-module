//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2021. 11. 24..
//

import Fluent
import Feather

final class UserRolePermissionModel: FeatherDatabaseModel {
    typealias Module = UserModule
    
    static var uniqueKey: String = "role_permissions"
    
    struct FieldKeys {
        struct v1 {
            static var roleId: FieldKey { "role_id" }
            static var permissionId: FieldKey { "permission_id" }
        }
    }

    @ID() var id: UUID?
    @Field(key: FieldKeys.v1.roleId) var roleId: UUID
    @Field(key: FieldKeys.v1.permissionId) var permissionId: UUID

    init() {}

    init(roleId: UUID, permissionId: UUID) {
        self.roleId = roleId
        self.permissionId = permissionId
    }
}

