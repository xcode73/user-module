//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 02. 23..
//

import SwiftSgml
import Feather

public protocol UserModuleTemplate: FeatherTemplate {
    func login(_ context: UserLoginContext) -> AbstractTemplate<UserLoginContext>
    func register(_ context: UserRegisterContext) -> AbstractTemplate<UserRegisterContext>
    func newPassword(_ context: UserNewPasswordContext) -> AbstractTemplate<UserNewPasswordContext>
    func resetPassword(_ context: UserResetPasswordContext) -> AbstractTemplate<UserResetPasswordContext>
}
