//
//  LoginView.swift
//  Project3
//
//  Created by Anushka R on 3/30/26.
//

import SwiftUI
import Supabase

struct LoginView: View {
    @ObservedObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // F1 Branding
                Image(systemName: "f1.stopwatch.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.red)
                    .padding(.bottom, 20)
                
                Text("Welcome to My F1")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Login Fields
                VStack(spacing: 15) {
                    TextField("Email", text: $viewModel.email)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.horizontal)
                
                // Error Message Display
                if let error = viewModel.authError {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button {
                        Task { await viewModel.signIn() }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Login")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Button {
                        Task { await viewModel.signUp() }
                    } label: {
                        Text("Create Account")
                            .fontWeight(.semibold)
                    }
                    .padding()
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 50)
        }
    }
}

#Preview {
    // Create a dummy client for the preview environment
    let mockClient = SupabaseClient(
        supabaseURL: URL(string: "https://example.supabase.co")!,
        supabaseKey: "mock-key"
    )
    let viewModel = AuthViewModel(client: mockClient)
    
    return LoginView(viewModel: viewModel)
}
