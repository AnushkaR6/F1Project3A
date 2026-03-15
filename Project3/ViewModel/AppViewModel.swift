//
//  AppViewModel.swift
//  Project3
//
//  Created by Anushka R on 3/14/26.
//

import SwiftUI
import Combine

class AppViewModel: ObservableObject {
    // 1. Instantiate the Model (The source of truth)
    @Published private var model = AppModel()
    
    // 2. UI State for showing the modals
    @Published var isShowingImagePicker = false
    @Published var isShowingCamera = false
    
    // 3. Accessor for the View to see the posts
    // This allows the View to read data without modifying the Model directly.
    var posts: [Post] {
        return model.posts
    }
    
    // 4. Requirement: Use this function to handle images from the Pickers
    func addPostFrom(image: UIImage?) {
        // Make sure the optional is an actual image
        guard let image else { return }
        
        // UI updates must happen on the main thread
        DispatchQueue.main.async {
            // Create a new post object using the currentUser as the author
            let newPost = Post(
                image: Image(uiImage: image),
                description: "New Race Memory",
                isFavorite: false,
                author: User.currentUser
            )
            
            // Call the mutating logic on the model
            // Requirement: New photos will appear at the top via model.add
            self.model.add(post: newPost)
        }
    }
    
    // 5. Requirement: Logic to remove photos
    // Only the User’s images can be deleted
    func deletePost(post: Post) {
        if post.author == User.currentUser {
            model.remove(postID: post.id)
        }
    }
}
