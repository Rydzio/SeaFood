//
//  ViewController.swift
//  SeaFood
//
//  Created by Michał Rytych on 25/02/2022.
//

import UIKit
import CoreML
import Vision

class ViewController:   UIViewController,
                        UIImagePickerControllerDelegate,
                        UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        
        #if targetEnvironment(simulator)
        // your simulator code
        imagePicker.sourceType = .photoLibrary
        #else
        // your real device code
        imagePicker.sourceType = .camera
        #endif
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
        imageView.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("could not convert to CIImage")
            }
            
            detect(image: ciimage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect (image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3(configuration: .init()).model) else {
            fatalError("Loading CoreML model failed")
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
            if let firstResult = results.first {
                
                self.navigationItem.title = firstResult.identifier
//                if firstResult.identifier.contains("hotdog") {
//                    self.navigationItem.title = "HOTDOG!"
//                } else {
//                    self.navigationItem.title = "NOT HOTDOG!"
//                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        do {
        try handler.perform([request])
        } catch {
            print(error)
        }
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    

}

