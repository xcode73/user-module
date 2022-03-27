//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 03. 15..
//

import Foundation

public struct UserConfig {

    public let login: String
    public let register: String
    public let resetPassword: String
    public let newPassword: String
    public let logout: String
    public let redirectQueryKey: String

    static var `default`: UserConfig = .init(login: "login",
                                             register: "register",
                                             resetPassword: "reset-password",
                                             newPassword: "new-password",
                                             logout: "logout",
                                             redirectQueryKey: "redirect")
}
