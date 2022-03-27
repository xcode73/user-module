//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2021. 11. 23..
//

import Vapor
import Feather
import UserObjects

struct UserRouter: FeatherRouter {
    
    let authController = UserAuthController()
    let authApiController = UserAuthApiController()
    let accountController = UserAccountAdminController()
    let accountApiController = UserAccountApiController()
    let roleController = UserRoleAdminController()
    let roleApiController = UserRoleApiController()
    let profileController = UserProfileAdminController()
    let invitationController = UserInvitationAdminController()

    func webRoutesHook(args: HookArguments) {
        let sessionRoutes = args.routes.grouped(UserAccountSessionAuthenticator())
        
        sessionRoutes
            .get("login", use: authController.loginView)
        args.routes
            .post("login", use: authController.login)
        sessionRoutes
            .get("logout", use: authController.logout)
        
        sessionRoutes
            .get("register", use: authController.registerView)
        sessionRoutes
            .post("register", use: authController.register)
        
        sessionRoutes
            .get("reset-password", use: authController.resetPasswordView)
        sessionRoutes
            .post("reset-password", use: authController.resetPassword)
        
        sessionRoutes
            .get("new-password", use: authController.newPasswordView)
        sessionRoutes
            .post("new-password", use: authController.newPassword)
        
    }
    
    func adminRoutesHook(args: HookArguments) {
        accountController.setUpRoutes(args.routes)
        invitationController.setUpRoutes(args.routes)
        invitationController.setUpInvitationRoutes(args.routes)
        
        roleController.setUpRoutes(args.routes)
        profileController.setUpDetailRoutes(args.routes)
        profileController.setUpUpdateRoutes(args.routes)
        
        args.routes.get(User.pathKey.pathComponent) { req -> Response in
            let template = SystemAdminModulePageTemplate(.init(title: "User",
                                                         tag: UserAdminWidgetTemplate().render(req)))
            return req.templates.renderHtml(template)
        }
    }
    
    func publicApiRoutesHook(args: HookArguments) {
        args.routes
            .post("login", use: authApiController.loginApi)

        args.routes
            .post("register", use: authApiController.registerApi)
        
        args.routes
            .post("reset-password", use: authApiController.resetPasswordApi)
        
        args.routes
            .post("new-password", use: authApiController.newPasswordApi)

    }

    func apiRoutesHook(args: HookArguments) {
        args.routes
            .get("profile", use: authApiController.profileApi)
        
        accountApiController.setUpRoutes(args.routes)
        roleApiController.setUpRoutes(args.routes)

//        permissionController.setupApiRoutes(args.routes)
    }
}
