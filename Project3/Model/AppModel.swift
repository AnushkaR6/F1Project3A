//
//  AppModel.swift
//  Project3
//
//  Created by Anushka R on 3/14/26.
//

import Foundation

class AppModel {
    // Private setter ensures only this class can modify the array directly
    private(set) var posts: [Post] = []
    
    // Having new photos be placed at the top
    func add(post: Post) {
        posts.insert(post, at: 0) //
    }
    
    // Removing photos
    func remove(postID: UUID) {
        posts.removeAll { $0.id == postID } //
    }
}
