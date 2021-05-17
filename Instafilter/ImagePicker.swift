//
//  ImagePicker.swift
//  Instafilter
//
//  Created by Brandon Knox on 5/15/21.
//

import SwiftUI

/*
 Process
 1. create SwiftUI view that conformed to UIViewControllerRepresentable
 2. Gave it a makeUIViewController method that created a UIKit View Controller (UIImagePickerController)
 3. Added nested coordinator class as a bridge between the UIKit View Controller and our SwiftUI view
 4. We gave that coordinator a didFinishPickingMediaWithInfo method which we triggered by UIKit when an image was chosen
 5. We gave our image picker an @Binding property so it can send images back to the parent view
 */

struct ImagePicker: UIViewControllerRepresentable {
    // NSObject is parent class of everything in UIKit - lets ObjC check for functionality
    // NSImagePickerControllerDelegate allows us to add activities when user picks an image (provides functionality)
    // UINavigationControllerDelegate detects when user moves between screens in image picker
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        // start typing didFinish and choose autocomplete
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as?
            UIImage {
                parent.image = uiImage
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    // needed to conform to UIViewControllerRepresentable
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {

    }

}
