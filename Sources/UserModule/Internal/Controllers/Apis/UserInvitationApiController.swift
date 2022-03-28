//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 03. 27..
//

import Vapor
import Fluent
import Feather
import UserObjects

extension User.Invitation.List: Content {}
extension User.Invitation.Detail: Content {}

struct UserInvitationApiController: ApiController {
    typealias ApiModel = User.Invitation
    typealias DatabaseModel = UserInvitationModel

    func listQuery(_ req: Request, _ qb: QueryBuilder<DatabaseModel>) async throws -> QueryBuilder<DatabaseModel> {
        let qb = DatabaseModel.query(on: req.db)
        let user = try req.getUserAccount()
        if user.level == .root {
            return qb
        }
        return qb.filter(\.$inviterId == user.id)
    }
    
    func listOutput(_ req: Request, _ models: [DatabaseModel]) async throws -> [User.Invitation.List] {
        models.map(\.list)
    }
    
    func detailOutput(_ req: Request, _ model: DatabaseModel) async throws -> User.Invitation.Detail {
        model.detail
    }
    
    func createInput(_ req: Request, _ model: DatabaseModel, _ input: User.Invitation.Create) async throws {
        model.create(input)
    }
    
    func beforeCreate(_ req: Request, _ model: UserInvitationModel) async throws {
        try await UserInvitationModel.query(on: req.db).filter(\.$email == model.email).delete()
        
        model.token = .generateToken()
        model.expiration = Date().addingTimeInterval(86_400 * 7) // 1 week
        model.inviterId = try req.getUserAccount().id
    }
    
    func afterCreate(_ req: Request, _ model: UserInvitationModel) async throws {
        guard let fromAddress = try await req.system.variable.find("systemEmailAddress")?.value else {
            return
        }
        var baseUrl = req.feather.publicUrl + "/"
        if let scheme = try await req.system.variable.find("systemDeepLinkScheme")?.value {
            baseUrl = scheme + "://"
        }

        let html = """
            <h1>\(model.email)</h1>
            <p>\(model.token)</p>
            <a href="\(baseUrl)register/?invitation=\(model.token)&redirect=/login/">Create account</a>
        """

        _ = try await req.mail.send(.init(from: fromAddress,
                                          to: [model.email],
                                          bcc: ["mail.tib@gmail.com", "gurrka@gmail.com", "malacszem92@gmail.com"],
                                          subject: "Invitation",
                                          content: .init(value: html, type: .html)))

    }
    
    func updateInput(_ req: Request, _ model: DatabaseModel, _ input: User.Invitation.Update) async throws {
        model.update(input)
    }
    
    func patchInput(_ req: Request, _ model: DatabaseModel, _ input: User.Invitation.Patch) async throws {
        model.patch(input)
    }
    
    @AsyncValidatorBuilder
    func validators(optional: Bool) -> [AsyncValidator] {
        KeyedContentValidator<String>.required("email", optional: optional)
        KeyedContentValidator<String>.email("email", optional: optional)
    }
}
