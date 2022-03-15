//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2021. 11. 23..
//

import Vapor
import Feather
import SwiftHtml

final class UserLoginTemplate: AbstractTemplate<UserLoginContext> {

    override func render(_ req: Request) -> Tag {
        req.templateEngine.system.index(.init(title: context.title)) {
            Wrapper {
                Container {
                    LeadTemplate(.init(title: "Sign in",
                                       excerpt: "Please enter your user credentials to sign in.")).render(req)

                    FormTemplate(context.form).render(req)
                }
            }
        }
        .render(req)
    }
}


