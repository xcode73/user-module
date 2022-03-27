//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2021. 12. 01..
//

import Vapor
import Feather
import SwiftHtml
import FeatherIcons
import UserObjects

struct UserAdminWidgetTemplate: TemplateRepresentable {
    
    
    func links() -> [LinkContext] {
        [
            .init(label: "Profile",
                  path: "/admin/user/profile/",
                  absolute: true,
                  permission: User.Profile.permission(for: .detail).key),
            .init(label: "Accounts",
                  path: "/admin/user/accounts/",
                  absolute: true,
                  permission: User.Account.permission(for: .list).key),
            .init(label: "Invitations",
                  path: "/admin/user/invitations/",
                  absolute: true,
                  permission: User.Invitation.permission(for: .list).key),
            .init(label: "Roles",
                  path: "/admin/user/roles/",
                  absolute: true,
                  permission: User.Role.permission(for: .list).key),
        ]
    }
    
    @TagBuilder
    func render(_ req: Request) -> Tag {
        Svg.user
        H2("User")

        Ul {
            links().map { link in
                Li {
                    LinkTemplate(link).render(req)
                }
            }
        }
    }
}
