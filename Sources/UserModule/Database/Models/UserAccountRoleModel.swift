//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2021. 11. 24..
//

final class UserAccountRoleModel: FeatherDatabaseModel {
    typealias Module = UserModule
    
    static var uniqueKey: String = "account_roles"

    struct FieldKeys {
        struct v1 {
            static var accountId: FieldKey { "account_id" }
            static var roleId: FieldKey { "role_id" }
        }
    }

    @ID() var id: UUID?
    @Field(key: FieldKeys.v1.accountId) var accountId: UUID
    @Field(key: FieldKeys.v1.roleId) var roleId: UUID
    
    init() {}

    init(accountId: UUID, roleId: UUID) {
        self.accountId = accountId
        self.roleId = roleId
    }
}
