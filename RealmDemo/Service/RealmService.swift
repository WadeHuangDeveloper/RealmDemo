//
//  RealmService.swift
//  RealmDemo
//
//  Created by Huei-Der Huang on 2025/3/19.
//

import Foundation
import RealmSwift

class RealmService {
    static let shared = RealmService()
    
    private init() {
        
    }
    
    static func CreateUser(firstName: String, lastName: String, email: String) -> UserObject {
        let user = UserObject()
        user.firstName = firstName
        user.lastName = lastName
        user.email = email
        return user
    }
    
    func create(firstName: String, lastName: String, email: String) throws {
        do {
            let user = RealmService.CreateUser(firstName: firstName, lastName: lastName, email: email)
            let realm = try Realm()
            try realm.write {
                realm.add(user, update: .modified)
            }
        } catch {
            print("\(Self.self).\(#function) error: \(error.localizedDescription)")
            throw RealmServiceError.createError(error)
        }
    }
    
    func read() throws -> UserObject? {
        do {
            let realm = try Realm()
            return realm.objects(UserObject.self).first
        } catch {
            print("\(Self.self).\(#function) error: \(error.localizedDescription)")
            throw RealmServiceError.readError(error)
        }
    }
    
    func update(firstName: String, lastName: String, email: String) throws {
        do {
            let realm = try Realm()
            try realm.write {
                if let user = realm.objects(UserObject.self).first {
                    user.firstName = firstName
                    user.lastName = lastName
                    user.email = email
                } else {
                    let error = NSError(domain: "\(Self.self)", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
                    throw error
                }
            }
        } catch {
            print("\(Self.self).\(#function) error: \(error.localizedDescription)")
            throw RealmServiceError.updateError(error)
        }
    }
    
    func delete() throws {
        do {
            if let user = try read() {
                let realm = try Realm()
                try realm.write {
                    realm.delete(user)
                }
            } else {
                let error = NSError(domain: "\(Self.self)", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
                throw RealmServiceError.deleteError(error)
            }
        } catch {
            print("\(Self.self).\(#function) error: \(error.localizedDescription)")
            throw RealmServiceError.deleteError(error)
        }
    }
}
