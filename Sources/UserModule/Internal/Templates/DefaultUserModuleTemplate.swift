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

    func register(_ context: UserRegisterContext) -> AbstractTemplate<UserRegisterContext> {
        UserRegisterTemplate(context)
    }
    
    func newPassword(_ context: UserNewPasswordContext) -> AbstractTemplate<UserNewPasswordContext> {
        UserNewPasswordTemplate(context)
    }
    
    func resetPassword(_ context: UserResetPasswordContext) -> AbstractTemplate<UserResetPasswordContext> {
        UserResetPasswordTemplate(context)
    }
}
