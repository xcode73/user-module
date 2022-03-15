//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 02. 23..
//

import Vapor
import Feather


public extension HookName {
    static let installUserRoles: HookName = "install-user-roles"
    static let installUserAccounts: HookName = "install-user-accounts"
    static let installUserRolePermissions: HookName = "install-user-role-permissions"
    static let installUserAccountRoles: HookName = "install-user-account-roles"
}

//public struct UserConfig {
//    
//    public var login: String
//    public var register: String
//    public var resetPassword: String
//    public var newPassword: String
//    public var logout: String
//
//    public var redirectQueryKey: String
//}


public struct UserInterface {
    private var req: Request
    
    public var account: UserAccountApi { .init(.init(req)) }
    public var role: UserRoleApi { .init(.init(req)) }

    init(_ req: Request) {
        self.req = req
    }
}

public extension Request {
    var user: UserInterface { .init(self) }
}


