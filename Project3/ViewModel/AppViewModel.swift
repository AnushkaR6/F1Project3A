//
//  AppViewModel.swift
//  Project3
//
//  Created by Anushka R on 3/14/26.
//


import Foundation
import UIKit
import Combine

// Managing feed and posts
class AppViewModel: ObservableObject {
    // referencing AppModel as the data source
    @Published private var model = AppModel()
    
    // UI State vars controlling camera and gallery views
    @Published var isShowingImagePicker = false
    @Published var isShowingCamera = false
    
    // Read-only posts to View
    var posts: [Post] {
        return model.posts
    }
    
    // Chosen image used for post
    func addPostFrom(image: UIImage?) {
        guard let image = image else { return }
        
        DispatchQueue.main.async {
            // Creating a new post using the UIImage
            let newPost = Post(
                uiImage: image,
                description: "New Race Memory",
                isFavorite: false,
                author: User.currentUser
            )
            // Storing new post to model
            self.model.add(post: newPost)
        }
    }
    
    // Removing post if user selects it
    func deletePost(post: Post) {
        // Confirms user deleted posts
        if post.author == User.currentUser {
            objectWillChange.send()
            // Removing only the specific post being deleted by user
            model.remove(postID: post.id)
        }
    }
}
