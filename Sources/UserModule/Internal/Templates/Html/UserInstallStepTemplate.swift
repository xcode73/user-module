//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2021. 12. 25..
//

import Vapor
import Feather
import SwiftHtml

final class UserInstallStepTemplate: AbstractTemplate<UserInstallStepContext> {
    
    override func render(_ req: Request) -> Tag {
        req.templateEngine.system.index(.init(title: "Create root user")) {
            Wrapper {
                Container {
                    LeadTemplate(.init(title: "Create root user",
                                   excerpt: "Configure your root user account")).render(req)
                
                    FormTemplate(context.form).render(req)
                }
            }
        }
        .render(req)
    }
}
