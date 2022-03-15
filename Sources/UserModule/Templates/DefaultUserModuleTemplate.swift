//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 03. 15..
//

import Vapor
import Feather
import SwiftSgml

struct DefaultUserModuleTemplate: UserModuleTemplate {

    init() {}

    func login(_ context: UserLoginContext) -> AbstractTemplate<UserLoginContext> {
        UserLoginTemplate(context)
    }
}
