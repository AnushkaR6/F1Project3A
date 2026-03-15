//
//  Post.swift
//  Project3
//
//  Created by Anushka R on 3/14/26.
//

import SwiftUI

struct Post: Identifiable, Equatable {
    let id = UUID()
    let image: Image
    var description: String
    var isFavorite: Bool
    let author: User
}
