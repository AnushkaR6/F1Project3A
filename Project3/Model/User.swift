//
//  User.swift
//  Project3
//
//  Created by Anushka R on 3/14/26.
//

import Foundation

struct User: Equatable {
    let name: String
    let profileImageName: String
    
    // Global access to the current user for checking deletion permissions
    static let currentUser = User(name: "My F1", profileImageName: "person.circle.fill")
}
