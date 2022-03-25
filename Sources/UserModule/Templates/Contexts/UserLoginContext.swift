//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2021. 12. 23..
//

import Feather

public struct UserLoginContext {
    public let title: String
    public let message: String
    public let resetPassword: LinkContext
    public let form: FormContext
    
    public init(title: String, message: String, resetPassword: LinkContext, form: FormContext) {
        self.title = title
        self.message = message
        self.resetPassword = resetPassword
        self.form = form
    }
}
