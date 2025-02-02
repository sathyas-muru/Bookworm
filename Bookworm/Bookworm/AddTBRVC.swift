//
//  AddTBRVC.swift
//  Bookworm
//
//  Created by Sathyashri.Muruganandam on 2024-11-18.
//

import UIKit
import AVFoundation
import CoreData

class AddTBRVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let picker = UIImagePickerController()
    var chosenImage: UIImage?
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var selectImageButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Theme.setTheme(to: self, theme: themeSelector)
        saveButton.backgroundColor = fillColor
        selectImageButton.backgroundColor = bubbleColor
        
        picker.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Theme.setTheme(to: self, theme: themeSelector)
    }
    
    @IBAction func selectImage(_ sender: Any) {
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let selectedImage = info[.originalImage] as? UIImage {
            chosenImage = selectedImage
            errorLabel.text = "Cover selected"
        }
        dismiss(animated:true)
        
    }
    
    @IBAction func saveButton(_ sender: Any) {
        // check if all fields are filled
        
        if titleField.text == "" {
            errorLabel.text = "Title not entered"
        } else if let image = chosenImage {
            var newTBR = TBR(title: titleField.text!, cover: image)
            TBRList.append(newTBR)
            
            // Save TBR to Core data
            let imgData = image.jpegData(compressionQuality: 1.0)
            let coreBook = NSEntityDescription.insertNewObject(forEntityName: "SavedTBR", into: context)
            coreBook.setValue(titleField.text!, forKey:"title")
                        coreBook.setValue(imgData, forKey: "cover")
                        saveContext()
            print("Sucessfully saved to core data")
            performSegue(withIdentifier: "savedTBRSegue", sender: nil)
        } else {
            errorLabel.text = "Image not selected"
        }
        
    }
    
    func saveContext () {
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
}
