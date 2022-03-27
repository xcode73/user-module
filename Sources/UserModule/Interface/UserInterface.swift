//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 02. 23..
//

import Vapor
import Feather

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
