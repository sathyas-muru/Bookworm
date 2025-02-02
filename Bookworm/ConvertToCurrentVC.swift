//
//  ConvertToCurrentVC.swift
//  Bookworm
//
//  Created by Sathyashri.Muruganandam on 2024-11-25.
//

import UIKit
import CoreData

class ConvertToCurrentVC: UIViewController {
    
    var book: TBR!
    var selectedDate: Date?
    var newBook: CurrentBook!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var coverImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = book.title
        coverImage.image = book.cover
        
        Theme.setTheme(to: self, theme: themeSelector)
        saveButton.backgroundColor = fillColor
        selectedDate = datePicker.date
    }
    
    @IBAction func dateChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
    }
    
    @IBAction func saveButton(_ sender: Any) {
        newBook = CurrentBook(title: book.title, cover: book.cover, date: selectedDate!)
        currentBookList.append(newBook)
        
        // add to core data
        let imgData = book.cover.jpegData(compressionQuality: 1.0)
        let coreBook = NSEntityDescription.insertNewObject(forEntityName: "SavedCurrentBook", into: context)
        coreBook.setValue(book.title, forKey: "title")
        coreBook.setValue(selectedDate!, forKey: "date")
        coreBook.setValue(imgData, forKey: "cover")
        do {
            try saveContext()
            print("Sucessfully saved to core data")
        } catch {
            print("Not able to save to core data")
        }
            
        // remove from TBR list
        if let index = TBRList.firstIndex(where: { $0.title == book.title }) {
            TBRList.remove(at: index)
        }
        
        // delete from core data
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "SavedTBR")
            fetchRequest.predicate = NSPredicate(format: "title == %@", book.title)
            
            do {
                let fetchResults = try context.fetch(fetchRequest)
                for object in fetchResults {
                    if let objectToDelete = object as? NSManagedObject {
                        context.delete(objectToDelete)
                    }
                }
                saveContext()
                print("Successfully deleted book from Core Data")
            } catch {
                print("Failed to delete book from Core Data: \(error)")
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
