//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 02. 23..
//

import Vapor
import Feather

public struct UserInterface {
    
    private let req: Request

    public let account: UserAccountApi
    public let role: UserRoleApi
    public let profile: UserProfileApi
    public let invitation: UserInvitationApi

    init(_ req: Request) {
        self.req = req
        
        self.account = .init(.init(req))
        self.role = .init(.init(req))
        self.profile = .init(.init(req))
        self.invitation = .init(.init(req))
    }
}

public extension Request {
    var user: UserInterface { .init(self) }
}
