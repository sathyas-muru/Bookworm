//
//  AddCurrentBookVC.swift
//  Bookworm
//
//  Created by Sathyashri.Muruganandam on 2024-11-18.
//

import UIKit
import AVFoundation
import CoreData

class AddCurrentBookVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    let picker = UIImagePickerController()
    var chosenImage: UIImage?
    let dateFormatter = DateFormatter()
    var selectedDate: Date?
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var uploadButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Theme.setTheme(to: self, theme: themeSelector)
        saveButton.backgroundColor = fillColor
        uploadButton.backgroundColor = bubbleColor
        
        picker.delegate = self
        dateFormatter.dateFormat = "MM/dd/yyyy"
        selectedDate = datePicker.date
    }
    
    
    @IBAction func selectImage(_ sender: Any) {
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let selectedImage = info[.originalImage] as? UIImage {
            chosenImage = selectedImage
            errorLabel.text = "Cover Selected"
        }
        dismiss(animated:true)
        
    }
    
    @IBAction func dateChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
    }
    
    @IBAction func saveButton(_ sender: Any) {
        // check if all fields are filled
        
        if titleField.text == "" {
            errorLabel.text = "Title not entered"
        } else if let image = chosenImage {
            var newBook = CurrentBook(title: titleField.text!, cover: chosenImage!, date: selectedDate!)
            currentBookList.append(newBook)
            
            // Save book to core data
            let imgData = chosenImage!.jpegData(compressionQuality: 1.0)
            let coreBook = NSEntityDescription.insertNewObject(forEntityName: "SavedCurrentBook", into: context)
            coreBook.setValue(titleField.text!, forKey: "title")
            coreBook.setValue(selectedDate, forKey: "date")
            coreBook.setValue(imgData, forKey: "cover")
            saveContext()
            print("Sucessfully saved to core data")
            
            performSegue(withIdentifier: "savedAddBookSegue", sender: nil)
            
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
