//
//  PostFeedView.swift
//  Project3
//
//  Created by Anushka R on 3/14/26.


import SwiftUI

struct PostFeedView: View {
    // Access the logic with MVVM
    @ObservedObject var viewModel: AppViewModel
    @State private var postToDelete: Post?
    
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
                        Image(systemName: post.author.profileImageName)
                            .foregroundColor(.red)
                        Text(post.author.name)
                            .font(.headline)
                        Spacer()
                        if post.author == User.currentUser {
                            Button {
                                postToDelete = post
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.borderless)
                            .accessibilityLabel("Delete")
                        }
                    }
                    
                    // Square crop using AspectImage
                    AspectImage(Image(uiImage: post.uiImage))
                        .cornerRadius(12)
                    
                    Text(post.description)
                        .font(.body)
                }
                .padding(.vertical, 8)
                .listRowSeparator(.hidden)
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
