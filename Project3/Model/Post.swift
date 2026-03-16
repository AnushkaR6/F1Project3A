//
//  Post.swift
//  Project3
//
//  Created by Anushka R on 3/14/26.
//

//import SwiftUI
//import UIKit
//
//// Setting up custom struct/ array by defining Post var to allow iteration
//// For post structure
//struct Post: Identifiable, Equatable {
//    let id = UUID()
//    let image: Image
//    var description: String
//    var isFavorite: Bool
//    let author: User
//}

import Foundation
import UIKit // Use UIKit for UIImage, not SwiftUI for Image

struct Post: Identifiable, Equatable {
    let id = UUID()
    let uiImage: UIImage // Changed from Image to UIImage
    var description: String
    var isFavorite: Bool
    let author: User
}
