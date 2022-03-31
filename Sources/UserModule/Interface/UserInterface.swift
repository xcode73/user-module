//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 02. 23..
//

import Vapor
import Fluent
import Feather

public struct UserInterface {
    
    private let db: Database

    public let account: UserAccountApi
    public let accountRole: UserAccountRoleApi
    public let role: UserRoleApi
    public let profile: UserProfileApi
    public let invitation: UserInvitationApi

    init(_ db: Database) {
        self.db = db
        
        self.account = .init(.init(db))
        self.accountRole = .init(.init(db))
        self.role = .init(.init(db))
        self.profile = .init(.init(db))
        self.invitation = .init(.init(db))
    }
}

public extension Request {
    var user: UserInterface { .init(db) }
}

public extension Application {
    var user: UserInterface { .init(db)}
}



