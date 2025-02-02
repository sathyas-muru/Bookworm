//
//  DoneBookVC.swift
//  Bookworm
//
//  Created by Sathyashri.Muruganandam on 2024-11-24.
//

import UIKit
import CoreData

class DoneBookVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var book: DoneBook!
    
    @IBOutlet weak var titleField: UILabel!
    @IBOutlet weak var dateField: UILabel!
    @IBOutlet weak var finishedDate: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var coverImage: UIImageView!

    // stoyboard outlets
    @IBOutlet weak var star1Image: UIImageView!
    @IBOutlet weak var star2Image: UIImageView!
    @IBOutlet weak var star3Image: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var star4Image: UIImageView!
    @IBOutlet weak var star5image: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting theme
        Theme.setTheme(to: self, theme: themeSelector)
        deleteButton.backgroundColor = fillColor
        
        // Add the stars based on the rating
        if book.rating >= 1 {
            star1Image.image = UIImage(systemName: "star.fill")
            star1Image.tintColor = fillColor
        }
        if book.rating >= 2 {
            star2Image.image = UIImage(systemName: "star.fill")
            star2Image.tintColor = fillColor
        }
        if book.rating >= 3 {
            star3Image.image = UIImage(systemName: "star.fill")
            star3Image.tintColor = fillColor
        }
        if book.rating >= 4 {
            star4Image.image = UIImage(systemName: "star.fill")
            star4Image.tintColor = fillColor
        }
        if book.rating == 5 {
            star5image.image = UIImage(systemName: "star.fill")
            star5image.tintColor = fillColor
        }
        
        
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 200
        
        titleField.text = book.title
        coverImage.image = book.cover
        dateField.text = "Started: \(dateToString(book.dateStart))"
        finishedDate.text = "Finished: \(dateToString(book.dateDone))"
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
            
            let bookFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SavedDoneBook")
                bookFetchRequest.predicate = NSPredicate(format: "title == %@", bookTitle)
                
                do {
                    if let bookObject = try context.fetch(bookFetchRequest).first {
                        // Fetch the journal relationship
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
    
    @IBAction func deleteBook(_ sender: Any) {
        // remove book from doneBookList
        if let index = doneBookList.firstIndex(where: { $0.title == book.title }) {
            doneBookList.remove(at: index)
        }
        
        // Delete book from Core Data
        deleteBookFromCoreData(bookTitle: book.title)
    }
    
    func deleteBookFromCoreData(bookTitle: String) {
        let request = NSFetchRequest<NSManagedObject>(entityName: "SavedDoneBook")
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
