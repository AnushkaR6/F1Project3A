//
//  PostFeedView.swift
//  Project3
//
//  Created by Anushka R on 3/14/26.

import SwiftUI

struct PostFeedView: View {
    // Access the logic with MVVM
    @StateObject private var viewModel = AppViewModel()
    @State private var postToDelete: Post?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background color
                Color(.systemGroupedBackground).ignoresSafeArea()
                // creating list for posts
                if viewModel.posts.isEmpty {
                    emptyStateView
                } else {
                    feedList
                }
            }
            // page title
            .navigationTitle("My F1")
            // post features
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 15) {
                        // Camera button
                        Button { viewModel.isShowingCamera = true } label: {
                            Image(systemName: "camera.fill")
                        }
                        
                        // Photo library button
                        Button { viewModel.isShowingImagePicker = true } label: {
                            Image(systemName: "photo.on.rectangle.angled")
                        }
                    }
                }
            }
            // Slides/ present when true
            .sheet(isPresented: $viewModel.isShowingImagePicker) {
                ImagePicker(viewModel: viewModel)
            }
            // initializing photo library and view model
            .sheet(isPresented: $viewModel.isShowingCamera) {
                CameraPicker(viewModel: viewModel)
            }
        }
    }
    
    // The main list showing posts
    private var feedList: some View {
        List {
            ForEach(viewModel.posts, id: \.id) { post in
                VStack(alignment: .leading, spacing: 10) {
                    // User title or their "handle"
                    HStack {
                        Image(systemName: post.author.profileImageName)
                            .foregroundStyle(.red)
                            .font(.title3)
                        Text(post.author.name)
                            .font(.headline)
                        Spacer()
                        if post.author == User.currentUser {
                            Button {
                                postToDelete = post
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.borderless)
                            .foregroundStyle(.red)
                            .accessibilityLabel("Delete")
                        }
                    }
                    
                    // Square crop adjustment
                    AspectImage(post.image)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    
                    Text(post.description)
                        .font(.body)
                        .padding(.bottom, 5)
                }
                .padding(.vertical, 8)
                .listRowSeparator(.hidden)
                // Removing photos feature
                .swipeActions(edge: .trailing) {
                    if post.author == User.currentUser {
                        Button(role: .destructive) {
                            postToDelete = post
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        // warning/ notice to confirm before deleting photos
        .listStyle(.plain)
        .alert(item: $postToDelete) { post in
            Alert(
                title: Text("Delete Photo?"),
                message: Text("This will remove the photo from your feed."),
                primaryButton: .destructive(Text("Delete")) {
                    viewModel.deletePost(post: post)
                },
                secondaryButton: .cancel()
            )
        }
    }
    // empty page view before photos are added
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

#Preview {
    PostFeedView()
}
