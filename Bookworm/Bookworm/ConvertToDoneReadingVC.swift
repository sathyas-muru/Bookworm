//
//  ConvertToDoneReadingVC.swift
//  Bookworm
//
//  Created by Sathyashri.Muruganandam on 2024-11-24.
//

import UIKit
import CoreData

class ConvertToDoneReadingVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var book: CurrentBook!
    var selectedDate: Date?
    var pickerData = ["1", "2", "3", "4", "5"]
    let dateFormatter = DateFormatter()
    var doneBook: DoneBook?
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var ratingPicker: UIPickerView!
    @IBOutlet weak var saveButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // setting Theme
        Theme.setTheme(to: self, theme: themeSelector)
        saveButton.backgroundColor = fillColor
        
        coverImage.image = book.cover
        titleLabel.text = book.title
        dateLabel.text = dateToString(book.date)
        
        ratingPicker.delegate = self
        ratingPicker.dataSource = self
        dateFormatter.dateFormat = "MM/dd/yyyy"
        selectedDate = datePicker.date
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Theme.setTheme(to: self, theme: themeSelector)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    @IBAction func dateChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        let pickerRow = ratingPicker.selectedRow(inComponent: 0)
        let pickerValue = pickerData[pickerRow]
        doneBook = DoneBook(title: book.title, cover: book.cover, rating: Int(pickerValue)!, dateDone: selectedDate!, dateStart: book.date, entries: book.entries)
        doneBookList.append(doneBook!)
        
        // update core data
        moveBookToDone(bookRating: Int(pickerValue)!)
        
        // remove current book from currentBook list
        if let index = currentBookList.firstIndex(where: { $0.title == book.title }) {
            currentBookList.remove(at: index)
        }
        
    }
    
    func moveBookToDone(bookRating: Int) {
        // Find the current book in Core Data
        let request = NSFetchRequest<NSManagedObject>(entityName: "SavedCurrentBook")
        request.predicate = NSPredicate(format: "title == %@", book.title)
        
        do {
            let fetchedBooks = try context.fetch(request)
            if let bookToMove = fetchedBooks.first {
                // Remove book from current books
                context.delete(bookToMove)
                
                // Create a new DoneBook object
                let entity = NSEntityDescription.entity(forEntityName: "SavedDoneBook", in: context)!
                let newDoneBook = NSManagedObject(entity: entity, insertInto: context)
                
                newDoneBook.setValue(book.title, forKey: "title")
                newDoneBook.setValue(book.cover.pngData(), forKey: "cover")
                newDoneBook.setValue(selectedDate!, forKey: "doneDate")
                newDoneBook.setValue(book.date, forKey: "startDate")
                newDoneBook.setValue(bookRating, forKey: "rating")
                
                // Copy journal entries
                if let journalEntries = bookToMove.value(forKey: "journal") as? Set<NSManagedObject> {
                    for journal in journalEntries {
                        let journalEntity = NSEntityDescription.entity(forEntityName: "SavedJournal", in: context)!
                        let newJournalEntry = NSManagedObject(entity: journalEntity, insertInto: context)
                        
                        newJournalEntry.setValue(journal.value(forKey: "content"), forKey: "content")
                        newJournalEntry.setValue(journal.value(forKey: "date"), forKey: "date")
                        
                        // Add journal entry to the new book
                        var currentJournalSet = newDoneBook.mutableSetValue(forKey: "journal")
                        currentJournalSet.add(newJournalEntry)
                    }
                }
                
            }
            
            // Save changes to Core Data
            try context.save()
        } catch {
            print("Error moving book to Done: \(error)")
        }
    }

    
    func dateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy" // Define the desired format
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        return dateFormatter.string(from: date)
    }
    
    func stringtoDate(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        return dateFormatter.date(from: dateString)
    }
}
