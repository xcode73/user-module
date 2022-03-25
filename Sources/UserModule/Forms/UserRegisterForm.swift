//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 02. 28..
//

import Vapor
import Feather

final class UserRegisterForm: AbstractForm {
    
    var imageKey: String?
    var firstName: String?
    var lastName: String?
    var email: String = ""
    var password: String = ""
     
    init() {
        super.init()
        self.submit = "Create account"
    }

    @FormFieldBuilder
    override func createFields(_ req: Request) -> [FormField] {
        ImageField("image", path: "user/account")
            .read { [unowned self] in
                if let key = imageKey {
                    $1.output.context.previewUrl = $0.fs.resolve(key: key)
                }
                ($1 as! ImageField).imageKey = imageKey
            }
            .write { [unowned self] in imageKey = ($1 as! ImageField).imageKey }
                
        InputField("firstName")
            .config {
                $0.output.context.label.title = "First name"
            }
            .read { [unowned self] in $1.output.context.value = firstName }
            .write { [unowned self] in firstName = $1.input }
        
        InputField("lastName")
            .config {
                $0.output.context.label.title = "Last name"
            }
            .read { [unowned self] in $1.output.context.value = lastName }
            .write { [unowned self] in lastName = $1.input }
        
        InputField("email")
            .config {
                $0.output.context.type = .email
                $0.output.context.label.required = true
            }
            .validators {
                FormFieldValidator.required($1)
                FormFieldValidator.email($1)
            }
            .read { [unowned self] in $1.output.context.value = email }
            .write { [unowned self] in email = $1.input }

        InputField("password")
            .config {
                $0.output.context.type = .password
                $0.output.context.label.required = true
            }
            .validators {
                FormFieldValidator.required($1)
            }
            .read { [unowned self] in $1.output.context.value = password }
            .write { [unowned self] in password = $1.input }
    }
}
