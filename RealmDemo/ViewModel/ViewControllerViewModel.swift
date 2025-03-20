//
//  ViewControllerViewModel.swift
//  RealmDemo
//
//  Created by Huei-Der Huang on 2025/3/19.
//

import Foundation
import Combine

class ViewControllerViewModel {
    var userSubject = CurrentValueSubject<UserObject?, RealmServiceError>(nil)
    var statusObject = PassthroughSubject<RealmServiceStatus, RealmServiceError>()
    
    private func createUser(firstName: String, lastName: String, email: String) -> UserObject {
        let userObject = UserObject()
        userObject.firstName = firstName
        userObject.lastName = lastName
        userObject.email = email
        return userObject
    }
    
    private func create(firstName: String, lastName: String, email: String) {
        do {
            try RealmService.shared.create(firstName: firstName, lastName: lastName, email: email)
            statusObject.send(.create)
            read()
        } catch {
            statusObject.send(completion: .failure(.createError(error)))
        }
    }
    
    private func update(firstName: String, lastName: String, email: String) {
        do {
            try RealmService.shared.update(firstName: firstName, lastName: lastName, email: email)
            statusObject.send(.update)
            read()
        } catch {
            statusObject.send(completion: .failure(.updateError(error)))
        }
    }
    
    func createOrUpdate(firstName: String, lastName: String, email: String) {
        if userSubject.value != nil {
            update(firstName: firstName, lastName: lastName, email: email)
        } else {
            create(firstName: firstName, lastName: lastName, email: email)
        }
    }
    
    func read() {
        do {
            if let user = try RealmService.shared.read() {
                userSubject.send(user)
            } else {
                userSubject.send(nil)
            }
        } catch {
            userSubject.send(completion: .failure(.readError(error)))
        }
    }
    
    func delete() {
        do {
            try RealmService.shared.delete()
            statusObject.send(.delete)
            read()
        } catch {
            statusObject.send(completion: .failure(.deleteError(error)))
        }
    }
}
