//
//  AppViewModel.swift
//  Project3
//
//  Created by Anushka R on 3/14/26.
//

import SwiftUI
import Combine

class AppViewModel: ObservableObject {
    // Instantiating the model
    @Published private var model = AppModel()
    
    // State for showing the modals
    @Published var isShowingImagePicker = false
    @Published var isShowingCamera = false
    
    // Connectings posts with view
    // Not modifying data directly
    var posts: [Post] {
        return model.posts
    }
    
    // Handling images from Picker
    func addPostFrom(image: UIImage?) {
        guard let image else { return }
        
        // Updates for main thread
        DispatchQueue.main.async {
            // Creating a new post object
            let newPost = Post(
                image: Image(uiImage: image),
                description: "New Race Memory",
                isFavorite: false,
                author: User.currentUser
            )
            
            // New photos appear at the top
            self.model.add(post: newPost)
        }
    }
    
    // Feature to delete user photos
    func deletePost(post: Post) {
        if post.author == User.currentUser {
            model.remove(postID: post.id)
        }
    }
}

