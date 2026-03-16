//
//  Post.swift
//  Project3
//
//  Created by Anushka R on 3/14/26.
//

import SwiftUI

// Setting up custom struct/ array by defining Post var to allow iteration
// For post structure
struct Post: Identifiable, Equatable {
    let id = UUID()
    let image: Image
    var description: String
    var isFavorite: Bool
    let author: User
}
