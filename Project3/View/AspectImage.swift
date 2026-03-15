//
//  AspectImage.swift
//  Project3
//
//  Created by Anushka R on 3/14/26.
//

import SwiftUI

struct AspectImage: View {
    let image: Image
    let aspectRatio: CGFloat

    var body: some View {
        GeometryReader { geometry in
            image
                .resizable()
                .scaledToFill()
                .frame(width: geometry.size.width, height: geometry.size.width / aspectRatio)
                .clipped()
        }
        .aspectRatio(aspectRatio, contentMode: .fit)
    }
}

// Preview to help you see it in Xcode
#Preview {
    AspectImage(image: Image(systemName: "car.fill"), aspectRatio: 1.0)
        .padding()
}
