//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 02. 28..
//

import SwiftSgml
import Feather

public struct UserResetPasswordContext {
    public let title: String
    public let message: String
    public let link: LinkContext
    public let form: FormContext
    
    public init(title: String, message: String, link: LinkContext, form: FormContext) {
        self.title = title
        self.message = message
        self.link = link
        self.form = form
    }
}
