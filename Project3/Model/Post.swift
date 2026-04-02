//
//  Post.swift
//  Project3
//
//  Created by Anushka R on 3/14/26.
//

import Foundation
import UIKit // Use UIKit for UIImage, not SwiftUI for Image
import Supabase

struct Post: Identifiable, Codable {
    let id: UUID
    let user_id: UUID
    let description: String
    let image_url: String // The URL from Supabase Storage
    let created_at: Date
}
    
//struct Post: Identifiable, Equatable {
//    let id = UUID()
//    let uiImage: UIImage // Changed from Image to UIImage
//    var description: String
//    var isFavorite: Bool
//    let author: User
//}
