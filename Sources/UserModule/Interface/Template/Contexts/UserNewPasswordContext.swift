//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 02. 28..
//

import SwiftSgml
import Feather

public struct UserNewPasswordContext {
    public let title: String
    public let message: String
    public let form: FormContext
    
    public init(title: String, message: String, form: FormContext) {
        self.title = title
        self.message = message
        self.form = form
    }
}
