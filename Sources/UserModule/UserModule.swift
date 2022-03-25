//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2021. 11. 23..
//

import Vapor
import Fluent
import Feather
import FeatherObjects
import UserObjects

struct UserModule: FeatherModule {
    
    let router = UserRouter()
    
    var template: UserModuleTemplate
    
    init(template: UserModuleTemplate) {
        self.template = template
    }
    
    func boot(_ app: Application) throws {
        app.templateEngine.register(template)

        app.migrations.add(UserMigrations.v1())
        app.databases.middleware.use(UserAccountModelMiddleware())
        
        app.hooks.register(.adminWidgets, use: adminWidgetsHook)
        
        app.hooks.register(.webMiddlewares, use: webMiddlewaresHook)
        app.hooks.register(.adminMiddlewares, use: adminMiddlewaresHook)
        app.hooks.register(.apiMiddlewares, use: apiMiddlewaresHook)

        app.hooks.register(.permission, use: permissionHook)
        app.hooks.register(.loginPath, use: loginPathHook)
        
        app.hooks.register(.webRoutes, use: router.webRoutesHook)
        app.hooks.register(.adminRoutes, use: router.adminRoutesHook)
        app.hooks.register(.apiRoutes, use: router.apiRoutesHook)
        app.hooks.register(.publicApiRoutes, use: router.publicApiRoutesHook)
        
        app.hooks.register(.installUserRoles, use: installUserRolesHook)
        app.hooks.register(.installUserRolePermissions, use: installRolePermissionsHook)
        app.hooks.register(.installPermissions, use: installUserPermissionsHook)
        app.hooks.register(.installStep, use: installStepHook)
        app.hooks.register(.installMenuItems, use: installMenuItemsHook)

        app.hooks.registerAsync(.install, use: installHook)
        app.hooks.registerAsync(.installResponse, use: installResponseHook)
        app.hooks.registerAsync(.access, use: accessHook)
        
        app.hooks.registerAsync(.guestRole, use: guestRole)
        app.hooks.registerAsync(.authenticatedRole, use: authenticatedRole)
        app.hooks.registerAsync(.rootRole, use: rootRole)
                
        try router.boot(app)
    }
    
    // MARK: - install
    
    func installStepHook(args: HookArguments) -> [SystemInstallStep] {
        [
            .init(key: Self.uniqueKey, priority: 9000),
        ]
    }
    
    func installResponseHook(args: HookArguments) async throws -> Response? {
        guard args.installInfo.currentStep == Self.uniqueKey else {
            return nil
        }
        return try await UserInstallStepController().handleInstallStep(args.req, info: args.installInfo)
    }

    func installHook(args: HookArguments) async throws {
        let roles: [User.Role.Create] = args.req.invokeAllFlat(.installUserRoles)
        try await roles.map { UserRoleModel(key: $0.key, name: $0.name, notes: $0.notes) }
            .create(on: args.req.db, chunks: 25)
        
        let accounts: [User.Account.Create] = args.req.invokeAllFlat(.installUserAccounts)
        try await accounts.map { UserAccountModel(email: $0.email,
                                                  password: try Bcrypt.hash($0.password)) }.create(on: args.req.db, chunks: 25)
        
        
        let rolePermissions: [User.RolePermission.Create] = args.req.invokeAllFlat(.installUserRolePermissions)
        for rolePermission in rolePermissions {
            guard let role = try await UserRoleRepository(args.req).find(rolePermission.key) else {
                continue
            }
            for permission in rolePermission.permissionKeys {
                guard let p = try await args.req.system.permission.get(permission) else {
                    continue
                }
                let rpm = UserRolePermissionModel(roleId: role.uuid, permissionId: p.id)
                try await rpm.create(on: args.req.db)
            }
        }
        
        let accountRoles: [User.AccountRole.Create] = args.req.invokeAllFlat(.installUserAccountRoles)
        for accountRole in accountRoles {
            guard let account = try await UserAccountRepository(args.req).find(accountRole.email) else {
                continue
            }
            for roleKey in accountRole.roleKeys {
                guard let role = try await UserRoleRepository(args.req).find(roleKey) else {
                    continue
                }
                let arm = UserAccountRoleModel(accountId: account.uuid, roleId: role.uuid)
                try await arm.create(on: args.req.db)
            }
        }
    }
    
    func installUserRolesHook(args: HookArguments) -> [User.Role.Create] {
        [
            .init(key: User.Role.Keys.Guest, name: "Guest", notes: "Guest users"),
            .init(key: User.Role.Keys.Authenticated, name: "Authenticated", notes: "Authenticated users"),
            .init(key: User.Role.Keys.Root, name: "Root", notes: "Root users"),
            /// custom user roles...
            .init(key: "editor", name: "Editor", notes: "Editor user role"),
        ]
    }
    
    func installRolePermissionsHook(args: HookArguments) -> [User.RolePermission.Create] {
        [
            .init(key: User.Role.Keys.Guest, permissionKeys: [
                "user.profile.create",
                "user.profile.login",
                "user.profile.invitation",
                "user.profile.reset-password",
                "user.profile.new-password",
            ]),
            .init(key: User.Role.Keys.Authenticated, permissionKeys: [
                "user.profile.detail",
                "user.profile.update",
                "user.profile.patch",
                "user.profile.delete",
                "user.profile.logout",
            ]),
//            .init(key: "root", permissionKeys: [
                // nothing to do here...
//            ])
        ]
    }
    
    func installUserPermissionsHook(args: HookArguments) -> [FeatherPermission.Create] {
        var permissions = User.availablePermissions()
        permissions += User.Account.availablePermissions()
        permissions += User.Permission.availablePermissions()
        permissions += User.Role.availablePermissions()
        permissions += [
            .init(namespace: "user", context: "profile", action: .detail),
            .init(namespace: "user", context: "profile", action: .create),
            .init(namespace: "user", context: "profile", action: .update),
            .init(namespace: "user", context: "profile", action: .patch),
            .init(namespace: "user", context: "profile", action: .delete),
            .init(namespace: "user", context: "profile", action: .custom("login")),
            .init(namespace: "user", context: "profile", action: .custom("logout")),
            .init(namespace: "user", context: "profile", action: .custom("reset-password")),
            .init(namespace: "user", context: "profile", action: .custom("new-password")),
            .init(namespace: "user", context: "profile", action: .custom("invitation")),
        ]
        return permissions.map { .init($0) }
    }
    
    func webMiddlewaresHook(args: HookArguments) -> [Middleware] {
        [
            UserAccountSessionAuthenticator()
        ]
    }
    
    func adminMiddlewaresHook(args: HookArguments) -> [Middleware] {
        [
            UserAccountSessionAuthenticator(),
        ]
    }
    
    func apiMiddlewaresHook(args: HookArguments) -> [Middleware] {
        var middlewares: [Middleware] = [
            UserAccountTokenAuthenticator(),
        ]
        if !args.app.feather.disableApiSessionAuthMiddleware {
            middlewares.append(UserAccountSessionAuthenticator())
        }
        return middlewares + [FeatherUser.guardMiddleware()]
    }
    
    func permissionHook(args: HookArguments) -> Bool {
        guard let user = args.req.auth.get(FeatherUser.self) else {
            return false
        }
        if user.hasRole(User.Role.Keys.Authenticated) && args.permission.key == "user.profile.login" {
            return false
        }
        return user.hasPermission(args.permission)
    }
    
    func accessHook(args: HookArguments) async throws -> Bool {
        permissionHook(args: args)
    }
    
    func guestRole(args: HookArguments) async throws -> FeatherRole? {
        try await args.req.user.role.repository.findWithPermissions(User.Role.Keys.Guest)
    }
    
    func authenticatedRole(args: HookArguments) async throws -> FeatherRole? {
        try await args.req.user.role.repository.findWithPermissions(User.Role.Keys.Authenticated)
    }
    
    func rootRole(args: HookArguments) async throws -> FeatherRole? {
        try await args.req.user.role.repository.findWithPermissions(User.Role.Keys.Root)
    }

    func adminWidgetsHook(args: HookArguments) -> [TemplateRepresentable] {
        if args.req.checkPermission(User.permission(for: .detail)) {
            return [
                UserAdminWidgetTemplate(),
            ]
        }
        return []
    }

    func loginPathHook(args: HookArguments) -> String {
        "/login/?redirect=/admin/"
    }

    func installMenuItemsHook(args: HookArguments) -> [FeatherMenuItem] {
        guard let key = args["menu-key"] as? String, key == "footer-account" else {
            return []
        }
        return [
            .init(label: "Admin", url: "/admin/", priority: 100, permission: "system.module.detail"),
            .init(label: "Sign in", url: "/login/", priority: 90, permission: "user.profile.login"),
            .init(label: "Sign out", url: "/logout/", priority: 90, permission: "user.profile.logout"),
        ]
    }
}

//extension FeatherPermission: CustomDebugStringConvertible {
//    public var debugDescription: String {
//        key
//    }
//}
//
//extension FeatherRole: CustomDebugStringConvertible {
//    public var debugDescription: String {
//        key + ": [" + permissions.map(\.debugDescription).joined(separator: ", ") + "]"
//    }
//}
