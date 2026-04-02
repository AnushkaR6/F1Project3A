//
//  ImagePicker.swift
//  Project3
//
//  Created by Anushka R on 3/14/26.

// combination of camera picker code provided in assignment & vibe coding

import SwiftUI
import PhotosUI
import Supabase

#if os(iOS)

struct ImagePicker: UIViewControllerRepresentable {
    
    var viewModel: AppViewModel

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider else { return }

            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    
                    // MARK: This is where I send the image from the photo library to the View Model. You should not edit this, instead you should make a ViewModel and a function called "addPostFrom" that works with this.
                    Task {
                        await self.parent.viewModel.addPostFrom(image: image as? UIImage, description: "")
                    }
                }
            }
        }
    }
}


struct ImagePicker_Previews: PreviewProvider {
    static var previews: some View {
        let supabase = SupabaseClient(
            supabaseURL: URL(string: "https://uawlvuoakvdlzwjrzrfn.supabase.co")!,
            supabaseKey: "sb_publishable_2CWSXyD0xh-yhE4CqkaW9A_NR_RJauc"
        )
        ImagePicker(viewModel: AppViewModel(supabase: supabase))
    }
}
#endif
