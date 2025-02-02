//
//  CurrentBookVC.swift
//  Bookworm
//
//  Created by Sathyashri.Muruganandam on 2024-11-23.
//

import UIKit
import CoreData

class CurrentBookVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var book: CurrentBook!
    
    @IBOutlet weak var titleField: UILabel!
    @IBOutlet weak var dateField: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var coverImage: UIImageView!
    
    @IBOutlet weak var addJournalBurron: UIButton!
    @IBOutlet weak var DoneReadingButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting theme
        Theme.setTheme(to: self, theme: themeSelector)
        deleteButton.backgroundColor = fillColor
        DoneReadingButton.backgroundColor = fillColor
        addJournalBurron.backgroundColor = fillColor
        
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 200
        
        titleField.text = book.title
        coverImage.image = book.cover
        dateField.text = dateToString(book.date)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return book.entries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextCell", for: indexPath)
        let row = indexPath.row
        cell.detailTextLabel?.text = book.entries[row].content
        cell.textLabel?.text = "Date: \(dateToString(book.entries[row].date))"
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.lineBreakMode = .byWordWrapping
        cell.backgroundColor = bubbleColor
        cell.textLabel?.textColor = .black
        cell.detailTextLabel?.textColor = .black
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteJournal(bookTitle: book.title, journal: book.entries[indexPath.row])
            book.entries.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func deleteJournal(bookTitle: String, journal: Journal) {
        // delete journal from core data
        
        let bookFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SavedCurrentBook")
            bookFetchRequest.predicate = NSPredicate(format: "title == %@", bookTitle)
            
            do {
                if let bookObject = try context.fetch(bookFetchRequest).first {
                    // Fetch the journal
                    if let journalEntries = bookObject.value(forKey: "journal") as? Set<NSManagedObject> {
                        // Locate the specific journal entry
                        if let journalObjectToDelete = journalEntries.first(where: {
                            $0.value(forKey: "content") as? String == journal.content &&
                            $0.value(forKey: "date") as? Date == journal.date
                        }) {
                            // Remove the journal entry
                            var updatedEntries = journalEntries
                            updatedEntries.remove(journalObjectToDelete)
                            bookObject.setValue(updatedEntries, forKey: "journal")
                            context.delete(journalObjectToDelete)
                            
                            // Save the context
                            try context.save()
                            print("Journal entry deleted successfully.")
                        } else {
                            print("Journal entry not found in the book's journal relationship.")
                        }
                    } else {
                        print("No journal entries found for the book in Core Data.")
                    }
                } else {
                    print("Book not found in Core Data.")
                }
            } catch {
                print("Failed to delete journal entry: \(error.localizedDescription)")
            }
        }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        Theme.setTheme(to: self, theme: themeSelector)
    }
    
    @IBAction func doneReadingButton(_ sender: Any) {
        // Perform segue to the DoneBookVC
        performSegue(withIdentifier: "ToDoneSegue", sender: nil)
    }
    
    @IBAction func addButton(_ sender: Any) {
        performSegue(withIdentifier: "AddJournalSegue", sender: nil)
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToDoneSegue" {
            // Pass the current book to the DoneBookVC
            if let destinationVC = segue.destination as? ConvertToDoneReadingVC {
                destinationVC.book = self.book
            }
        } else if segue.identifier == "AddJournalSegue" {
            if let destinationVC = segue.destination as? AddJournalVC {
                destinationVC.book = self.book
            }
        }
    }
    
    @IBAction func deleteBook(_ sender: Any) {
        
        if let index = doneBookList.firstIndex(where: { $0.title == book.title }) {
            doneBookList.remove(at: index)
        }
        
        // Delete book from Core Data
        deleteBookFromCoreData(bookTitle: book.title)
    }
    
    func deleteBookFromCoreData(bookTitle: String) {
        let request = NSFetchRequest<NSManagedObject>(entityName: "SavedCurrentBook")
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
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
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
