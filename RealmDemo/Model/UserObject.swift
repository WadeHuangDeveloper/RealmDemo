//
//  UserObject.swift
//  RealmDemo
//
//  Created by Huei-Der Huang on 2025/3/19.
//

import Foundation
import RealmSwift

class UserObject: Object {
    @Persisted(primaryKey: true) var id: ObjectId = ObjectId.generate()
    @Persisted var firstName: String = ""
    @Persisted var lastName: String = ""
    @Persisted var email: String = ""
}
