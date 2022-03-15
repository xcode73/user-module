//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2021. 12. 25..
//

import Vapor
import Feather
import SwiftHtml

struct UserInstallStepTemplate: TemplateRepresentable {
    
    var context: UserInstallStepContext
    
    init(_ context: UserInstallStepContext) {
        self.context = context
    }

    func render(_ req: Request) -> Tag {
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
