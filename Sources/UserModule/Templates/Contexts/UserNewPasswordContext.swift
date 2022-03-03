//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 02. 28..
//

import SwiftSgml

struct UserNewPasswordContext {
    var title: String
    var message: String
    var form: Tag
    
    init(title: String,
         message: String,
         form: Tag) {
        self.title = title
        self.message = message
        self.form = form
    }
}
