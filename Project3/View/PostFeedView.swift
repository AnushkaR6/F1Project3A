//
//  PostFeedView.swift
//  Project3
//
//  Created by Anushka R on 3/14/26.


import SwiftUI
import Supabase

struct PostFeedView: View {
    // Access the logic with MVVM
    @ObservedObject var viewModel: AppViewModel
    @ObservedObject var f1VM: F1ViewModel
    // Get the authViewModel to access the Supabase client
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var postToDelete: Post?
    
    // State to hold the text for a new comment
    @State private var newCommentText: String = ""

    private var currentUserID: UUID? {
        authViewModel.session?.user.id
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                if viewModel.posts.isEmpty {
                    emptyStateView
                } else {
                    feedList
                }
            }
            .navigationTitle("My F1")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 15) {
                        Button { viewModel.isShowingCamera = true } label: {
                            Image(systemName: "camera.fill")
                        }
                        
                        Button { viewModel.isShowingImagePicker = true } label: {
                            Image(systemName: "photo.on.rectangle.angled")
                        }
                        Button {
                            Task {
                                await authViewModel.signOut(f1VM: f1VM)
                            }
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Sign Out")
                            }
                            .foregroundColor(.red) // F1 Red branding
                        }
                    }
                }
            }
            .sheet(isPresented: $viewModel.isShowingImagePicker) {
                ImagePicker(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.isShowingCamera) {
                CameraPicker(viewModel: viewModel)
            }
        }
    }
    
    private var feedList: some View {
        List {
            ForEach(viewModel.posts) { post in
                VStack(alignment: .leading, spacing: 12) {
                    // Header
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(.red)
                        Text(post.user_id == currentUserID ? "My F1" : "F1 Fan")
                            .font(.headline)
                        Spacer()
                        
                        // Trash button logic remains same
                        if post.user_id == currentUserID {
                            Button {
                                postToDelete = post
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                    
//                    AspectImage(Image(uiImage: post.uiImage))
//                        .cornerRadius(12)
                    AsyncImage(url: URL(string: post.image_url)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        ProgressView() // Shows a spinner while the image downloads
                    }
                    .frame(height: 300)
                    
                    Text(post.description)
                        .font(.body)
                    
                    // MARK: - Step 4: Comment Section
                    commentSection(for: post)
                }
                .padding(.vertical, 8)
                .listRowSeparator(.hidden)
                .onAppear {
                    // Fetch comments from backend when post appears
                    Task {
                        await viewModel.fetchComments(for: post.id)
                    }
                }
            }
        }
        .listStyle(.plain)
    }

    // New sub-view for the comment area
    private func commentSection(for post: Post) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()
            
            Text("Comments")
                .font(.subheadline)
                .fontWeight(.bold)
            
            // Display existing comments for this post
            let postComments = viewModel.comments[post.id] ?? []
            if postComments.isEmpty {
                Text("No comments yet. Be the first!")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                ForEach(postComments) { comment in
                    HStack(alignment: .top) {
                        Text("F1 Fan:") // Placeholder for author name
                            .font(.caption)
                            .fontWeight(.bold)
                        Text(comment.content)
                            .font(.caption)
                    }
                }
            }

            // Input field to add a new comment
            HStack {
                TextField("Add a comment...", text: $newCommentText)
                    .textFieldStyle(.roundedBorder)
                    .font(.caption)
                
                Button {
                    let content = newCommentText
                    newCommentText = "" // Clear field immediately
                    Task {
                        await viewModel.addComment(text: content, postID: post.id)
                    }
                } label: {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.red)
                }
            }
            .padding(.top, 4)
        }
        .padding(.top, 4)
    }
    
    // This view shows up only when the feed is empty
        private var emptyStateView: some View {
            VStack(spacing: 20) {
                Image(systemName: "photo.stack")
                    .font(.system(size: 80))
                    .foregroundColor(.gray)
                Text("No Race Memories Yet")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Capture the action or upload from your gallery.")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
}
