//
//  AppViewModel.swift
//  Project3
//
//  Created by Anushka R on 3/14/26.
//

import Foundation
import UIKit
import Combine
import Supabase

@MainActor
class AppViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var posts: [Post] = []
    @Published var comments: [UUID: [Comment]] = [:] // Key is Post ID
    @Published var isLoading = false
    
    // UI State for Image Picking
    @Published var isShowingImagePicker = false
    @Published var isShowingCamera = false
    
    private let supabase: SupabaseClient
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }
    
    // MARK: - Post Actions
    
    /// Requirement: Persistence - Fetches all posts from the cloud database
    func fetchPosts() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let fetchedPosts: [Post] = try await supabase
                .from("posts")
                .select("*")
                .order("created_at", ascending: false)
                .execute()
                .value
            
            self.posts = fetchedPosts
        } catch {
            print("Error fetching posts: \(error)")
        }
    }
    
    /// Requirement: Scoping Logic - Uploads an image to Storage and links it to the user
    func addPostFrom(image: UIImage?, description: String) async {
        guard let image = image,
              let imageData = image.jpegData(compressionQuality: 0.5),
              let userId = supabase.auth.currentUser?.id else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        let fileName = "\(userId.uuidString)/\(UUID().uuidString).jpg"
        
        do {
            // 1. Upload to Storage bucket
            try await supabase.storage
                .from("post_images")
                .upload(
                    fileName,
                    data: imageData,
                    options: FileOptions(contentType: "image/jpeg")
                )
            
            // 2. Get Public URL
            // FIX: Removed 'try' and changed to 'getPublicURL' (all caps URL)
            let imageURL = try supabase.storage
                .from("post_images")
                .getPublicURL(path: fileName)
                .absoluteString
            
            // 3. Insert record into 'posts' table
            let postData: [String: AnyJSON] = [
                "user_id": .string(userId.uuidString),
                "description": .string(description),
                "image_url": .string(imageURL)
            ]
            
            try await supabase.from("posts").insert(postData).execute()
            
            // 4. Refresh local UI
            await fetchPosts()
            
        } catch {
            print("Error creating post: \(error)")
        }
    }
    
    /// Requirement: Scoping Logic - Deletes post only if owned by user
    func deletePost(post: Post) {
        guard let userId = supabase.auth.currentUser?.id else { return }
        
        Task {
            do {
                try await supabase
                    .from("posts")
                    .delete()
                    .eq("id", value: post.id.uuidString)
                    .eq("user_id", value: userId.uuidString)
                    .execute()
                
                self.posts.removeAll { $0.id == post.id }
            } catch {
                print("Error deleting post: \(error)")
            }
        }
    }
    
    // MARK: - Comment Actions
    
    func fetchComments(for postID: UUID) async {
        do {
            let fetchedComments: [Comment] = try await supabase
                .from("comments")
                .select()
                .eq("post_id", value: postID.uuidString)
                .order("created_at", ascending: true)
                .execute()
                .value

            self.comments[postID] = fetchedComments
        } catch {
            print("Error fetching comments: \(error)")
        }
    }
    
    func addComment(text: String, postID: UUID) async {
        guard !text.isEmpty,
              let userId = supabase.auth.currentUser?.id else { return }
        
        let newComment = [
            "post_id": postID.uuidString,
            "user_id": userId.uuidString,
            "content": text
        ]
        
        do {
            try await supabase.from("comments").insert(newComment).execute()
            await fetchComments(for: postID)
        } catch {
            print("Error posting comment: \(error)")
        }
    }
    
    func clearData() {
        self.posts = []
        self.comments = [:]
    }
}
