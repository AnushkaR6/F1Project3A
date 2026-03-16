//
//  CameraPicker.swift
//  Project3
//
//  Created by Anushka R on 3/14/26.
//

// combination of camera picker code provided in assignment & vibe coding

import SwiftUI

#if os(iOS)

struct CameraPicker: UIViewControllerRepresentable {
    var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let camera = UIImagePickerController()
        camera.sourceType = .camera
        camera.delegate = context.coordinator
        return camera
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // nothing here
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker
        
        init(_ parent: CameraPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                // MARK: This is where I send the image from the photo library to the View Model. You should not edit this, instead you should make a ViewModel and a function called "addPostFrom" that works with this.
                parent.viewModel.addPostFrom(image: image)
            }
            parent.dismiss()
        }
    }

    
}

struct CameraPicker_Previews: PreviewProvider {
    static var previews: some View {
        CameraPicker(viewModel: AppViewModel())
    }
}
#endif
