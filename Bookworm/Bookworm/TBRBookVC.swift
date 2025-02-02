//
//  TBRBookVC.swift
//  Bookworm
//
//  Created by Sathyashri.Muruganandam on 2024-11-23.
//

import UIKit
import CoreData

class TBRBookVC: UIViewController {
    
    var book: TBR!
    
    @IBOutlet weak var titleField: UILabel!
    @IBOutlet weak var coverImage: UIImageView!

    @IBOutlet weak var startReading: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Theme.setTheme(to: self, theme: themeSelector)
        startReading.backgroundColor = fillColor
        deleteButton.backgroundColor = fillColor
        
        titleField.text = book.title
        coverImage.image = book.cover
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Theme.setTheme(to: self, theme: themeSelector)
    }
    
    @IBAction func startReadingButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "toCurrentBookSegue", sender: nil)
    }
    
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        if let index = TBRList.firstIndex(where: { $0.title == book.title }) {
            TBRList.remove(at: index)
            
            // delete from core data
            deleteBookFromCoreData(bookTitle: book.title)
        }
    }
    
    func deleteBookFromCoreData(bookTitle: String) {
        let request = NSFetchRequest<NSManagedObject>(entityName: "SavedTBR")
        request.predicate = NSPredicate(format: "title == %@", bookTitle)
        
        do {
            let fetchedBooks = try context.fetch(request)
            if let bookToDelete = fetchedBooks.first {
                // Delete the book
                context.delete(bookToDelete)
                
                // Save changes
                saveContext()
                print("Book deleted successfully from Core Data.")
            } else {
                print("Book not found in Core Data.")
            }
        } catch {
            print("Error deleting book from Core Data: \(error)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCurrentBookSegue" {
            // Pass the current book to the DoneBookVC
            if let destinationVC = segue.destination as? ConvertToCurrentVC {
                destinationVC.book = self.book
            }
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
