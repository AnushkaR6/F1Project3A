//
//  PostFeedView.swift
//  Project3
//
//  Created by Anushka R on 3/14/26.
//

import SwiftUI

struct PostFeedView: View {
    // Access the logic through the ViewModel (MVVM)
    @StateObject private var viewModel = AppViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background color to make the feed pop
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                if viewModel.posts.isEmpty {
                    emptyStateView
                } else {
                    feedList
                }
            }
            .navigationTitle("F1 Feed")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 15) {
                        // Button for Camera
                        Button { viewModel.isShowingCamera = true } label: {
                            Image(systemName: "camera.fill")
                        }
                        
                        // Button for Photo Library
                        Button { viewModel.isShowingImagePicker = true } label: {
                            Image(systemName: "photo.on.rectangle.angled")
                        }
                    }
                }
            }
            // Modally present pickers (Requirement)
            .sheet(isPresented: $viewModel.isShowingImagePicker) {
                ImagePicker(image: Binding(
                    get: { nil },
                    set: { viewModel.addPostFrom(image: $0) }
                ))
            }
            .sheet(isPresented: $viewModel.isShowingCamera) {
                CameraPicker(image: Binding(
                    get: { nil },
                    set: { viewModel.addPostFrom(image: $0) }
                ))
            }
        }
    }
    
    // The main list showing posts
    private var feedList: some View {
        List {
            ForEach(viewModel.posts) { post in
                VStack(alignment: .leading, spacing: 10) {
                    // User Header
                    HStack {
                        Image(systemName: post.author.profileImageName)
                            .foregroundStyle(.red)
                            .font(.title3)
                        Text(post.author.name)
                            .font(.headline)
                        Spacer()
                    }
                    
                    // Square Crop (Requirement)
                    AspectImage(image: post.image, aspectRatio: 1.0)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    
                    Text(post.description)
                        .font(.body)
                        .padding(.bottom, 5)
                }
                .padding(.vertical, 8)
                .listRowSeparator(.hidden)
                // Remove photos (Requirement - Only user's own photos)
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        viewModel.deletePost(post: post)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.plain)
    }
    
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
    // To see data in the preview, ensure AppViewModel starts with dummy data or use your preview model
    PostFeedView()
}
