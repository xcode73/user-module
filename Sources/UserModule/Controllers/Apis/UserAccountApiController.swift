//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2021. 12. 01..
//

import Feather


extension User.Account.List: Content {}
extension User.Account.Detail: Content {}

struct UserAccountApiController: ApiController {
    typealias ApiModel = User.Account
    typealias DatabaseModel = UserAccountModel
    
    func listOutput(_ req: Request, _ models: [DatabaseModel]) async throws -> [User.Account.List] {
        models.map(\.list)
    }
    
    func detailOutput(_ req: Request, _ model: DatabaseModel) async throws -> User.Account.Detail {
        model.detail
    }
    
    func createInput(_ req: Request, _ model: DatabaseModel, _ input: User.Account.Create) async throws {
        model.create(input)
    }
    
    func updateInput(_ req: Request, _ model: DatabaseModel, _ input: User.Account.Update) async throws {
        model.update(input)
    }
    
    func patchInput(_ req: Request, _ model: DatabaseModel, _ input: User.Account.Patch) async throws {
        model.patch(input)
    }
    
    @AsyncValidatorBuilder
    func validators(optional: Bool) -> [AsyncValidator] {
        KeyedContentValidator<String>.required("email", optional: optional)
        KeyedContentValidator<String>.email("email", optional: optional)
        KeyedContentValidator<String>.required("password", optional: optional)
        KeyedContentValidator<String>("email", "Email must be unique", optional: optional) { req, value in
            try await req.user.account.repository.isUnique(\.$email == value, User.Account.getIdParameter(req))
        }
    }
}

extension User.Account.Create {
    
    @AsyncValidatorBuilder
    static var validators: [AsyncValidator] {
        KeyedContentValidator<String>.required("email")
        KeyedContentValidator<String>.email("email")
        KeyedContentValidator<String>.required("password")
        KeyedContentValidator<String>("email", "Email must be unique") { req, value in
            try await req.user.account.repository.isUnique(\.$email == value, User.Account.getIdParameter(req))
        }
    }
}

extension User.Account.Update {
    
    @AsyncValidatorBuilder
    static var validators: [AsyncValidator] {
        KeyedContentValidator<String>.required("email")
        KeyedContentValidator<String>.email("email")
        KeyedContentValidator<String>.required("password")
        KeyedContentValidator<String>("email", "Email must be unique") { req, value in
            try await req.user.account.repository.isUnique(\.$email == value, User.Account.getIdParameter(req))
        }
    }
}

extension User.Account.Patch {
    
    @AsyncValidatorBuilder
    static var validators: [AsyncValidator] {
        KeyedContentValidator<String>.required("email", optional: true)
        KeyedContentValidator<String>.email("email", optional: true)
        KeyedContentValidator<String>.required("password", optional: true)
        KeyedContentValidator<String>("email", "Email must be unique", optional: true) { req, value in
            try await req.user.account.repository.isUnique(\.$email == value, User.Account.getIdParameter(req))
        }
    }
}
