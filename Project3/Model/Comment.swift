//
//  Comment.swift
//  Project3
//
//  Created by Anushka R on 3/31/26.
//

import Foundation

struct Comment: Identifiable, Codable {
    let id: Int? // Optional because Supabase generates this
    let post_id: UUID
    let user_id: UUID
    let content: String
    let created_at: Date?
    
    // To display the user's name next to the comment
    var authorName: String {
        // In a real app, you'd fetch the username, for now we'll use a placeholder
        return "F1 Fan"
    }
}
