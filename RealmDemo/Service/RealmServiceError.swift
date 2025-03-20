//
//  RealmServiceError.swift
//  RealmDemo
//
//  Created by Huei-Der Huang on 2025/3/19.
//

import Foundation

enum RealmServiceError: Error {
    case createError(Error)
    case readError(Error)
    case updateError(Error)
    case deleteError(Error)
}
