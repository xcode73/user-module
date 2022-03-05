//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2021. 11. 23..
//

import Vapor
import Feather
import UserApi

struct UserRouter: FeatherRouter {
    
    let authController = UserAuthController()
    let authApiController = UserAuthApiController()
    let accountController = UserAccountAdminController()
    let roleController = UserRoleAdminController()
    let profileController = UserProfileAdminController()

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
//        accountController.setupApiRoutes(args.routes)
//        roleController.setupApiRoutes(args.routes)
//        permissionController.setupApiRoutes(args.routes)
    }
}
