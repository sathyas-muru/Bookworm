//
//  AddJournalVC.swift
//  Bookworm
//
//  Created by Sathyashri.Muruganandam on 2024-11-24.
//

import UIKit
import CoreData

class AddJournalVC: UIViewController, UITextViewDelegate {
    
    var selectedDate: Date?
    var book: CurrentBook!
    var entry: Journal!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var journalEntry: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set theme
        Theme.setTheme(to: self, theme: themeSelector)
        saveButton.backgroundColor = fillColor
        journalEntry.backgroundColor = bubbleColor
        journalEntry.delegate = self
        
        // Set Views
        journalEntry.layer.borderWidth = 1.0
        selectedDate = datePicker.date
    }
    
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
        
        // Called when the user clicks on the view outside of the UITextField

        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(true)
        }
    
    @IBAction func dateChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        entry = Journal(date: selectedDate!, content: journalEntry.text)
        book.entries.append(entry)
        
        // add journal entry to core data
        // retrive book from core data
        if let savedBook = fetchSavedBook(for: book.title, context: context) {
            addJournalEntry(toBook: savedBook, content: journalEntry.text, date: selectedDate!, context: context)
        } 
        // segue back to current book
        performSegue(withIdentifier: "backToCurrent", sender: book)
    }
    
    func fetchSavedBook(for title: String, context: NSManagedObjectContext) -> SavedCurrentBook? {
            let fetchRequest: NSFetchRequest<SavedCurrentBook> = SavedCurrentBook.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "title == %@", title) // Filter by book title
            
            do {
                let books = try context.fetch(fetchRequest)
                return books.first // Assuming titles are unique
            } catch {
                print("Failed to fetch book: \(error)")
                return nil
            }
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backToCurrent" {
            if let destinationVC = segue.destination as? CurrentBookVC,
               let selectedBook = sender as? CurrentBook {
                destinationVC.book = selectedBook
            }
        }
    }
            
    func addJournalEntry(toBook book: SavedCurrentBook, content: String, date: Date, context: NSManagedObjectContext) {
        // Create a new SaveJournal entry
        let newJournal = SavedJournal(context: context)
        newJournal.content = content
        newJournal.date = date
        
        // Link the journal entry to the book
        newJournal.book = book
        book.addToJournal(newJournal)
        
        // Save the context
        do {
            try context.save()
            print("Journal entry added successfully to the book!")
        } catch {
            print("Failed to add journal entry: \(error)")
        }
    }

}
