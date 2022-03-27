//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2021. 11. 23..
//

import Fluent

struct UserMigrations {

    struct v1: AsyncMigration {

        func prepare(on db: Database) async throws {
            try await db.schema(UserInvitationModel.schema)
                .id()
                .field(UserInvitationModel.FieldKeys.v1.email, .string, .required)
                .field(UserInvitationModel.FieldKeys.v1.value, .string, .required)
                .field(UserInvitationModel.FieldKeys.v1.expiration, .datetime, .required)
                .unique(on: UserInvitationModel.FieldKeys.v1.email)
                .create()
            
            try await db.schema(UserAccountModel.schema)
                .id()
                .field(UserAccountModel.FieldKeys.v1.imageKey, .string)
                .field(UserAccountModel.FieldKeys.v1.firstName, .string)
                .field(UserAccountModel.FieldKeys.v1.lastName, .string)
                .field(UserAccountModel.FieldKeys.v1.email, .string, .required)
                .field(UserAccountModel.FieldKeys.v1.password, .string, .required)
                .unique(on: UserAccountModel.FieldKeys.v1.email)
                .create()
            
            try await db.schema(UserTokenModel.schema)
                .id()
                .field(UserTokenModel.FieldKeys.v1.value, .string, .required)
                .field(UserTokenModel.FieldKeys.v1.accountId, .uuid, .required)
                .field(UserTokenModel.FieldKeys.v1.expiration, .datetime, .required)
                .foreignKey(UserTokenModel.FieldKeys.v1.accountId, references: UserAccountModel.schema, .id)
                .unique(on: UserTokenModel.FieldKeys.v1.value)
                .create()
            
            try await db.schema(UserRoleModel.schema)
                .id()
                .field(UserRoleModel.FieldKeys.v1.key, .string, .required)
                .field(UserRoleModel.FieldKeys.v1.name, .string, .required)
                .field(UserRoleModel.FieldKeys.v1.notes, .string)
                .unique(on: UserRoleModel.FieldKeys.v1.key)
                .create()
            
            try await db.schema(UserAccountRoleModel.schema)
                .id()
                .field(UserAccountRoleModel.FieldKeys.v1.accountId, .uuid, .required)
                .field(UserAccountRoleModel.FieldKeys.v1.roleId, .uuid, .required)
                .create()
            
            try await db.schema(UserRolePermissionModel.schema)
                .id()
                .field(UserRolePermissionModel.FieldKeys.v1.roleId, .uuid, .required)
                .field(UserRolePermissionModel.FieldKeys.v1.permissionId, .uuid, .required)
                .create()
            
            try await db.schema(UserResetPasswordModel.schema)
                .id()
                .field(UserResetPasswordModel.FieldKeys.v1.accountId, .uuid, .required)
                .field(UserResetPasswordModel.FieldKeys.v1.token, .string, .required)
                .field(UserResetPasswordModel.FieldKeys.v1.expiration, .datetime, .required)
                .unique(on: UserResetPasswordModel.FieldKeys.v1.accountId)
                .create()
        }
        
        func revert(on db: Database) async throws {
            try await db.schema(UserRolePermissionModel.schema).delete()
            try await db.schema(UserAccountRoleModel.schema).delete()
            try await db.schema(UserRoleModel.schema).delete()
            try await db.schema(UserTokenModel.schema).delete()
            try await db.schema(UserAccountModel.schema).delete()
            try await db.schema(UserResetPasswordModel.schema).delete()
            try await db.schema(UserInvitationModel.schema).delete()
        }
    }
}
