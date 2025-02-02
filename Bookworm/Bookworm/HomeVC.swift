//
//  HomeVC.swift
//  Bookworm
//
//  Created by Sathyashri.Muruganandam on 2024-11-22.
//

import UIKit
import CoreData

let appDelegate = UIApplication.shared.delegate as! AppDelegate
let context = appDelegate.persistentContainer.viewContext

// Variable to store theme
var themeSelector: Theme = .classic

// defining lists for each type of book
var TBRList: [TBR] = []
var currentBookList: [CurrentBook] = []
var doneBookList: [DoneBook] = []

// defining journal entry class
class Journal {
    var date: Date
    var content: String
    
    init(date: Date, content:String){
        self.date = date
        self.content = content
    }
}

// Defining classes for eahc type of book
class CurrentBook{
    var title: String
    var cover: UIImage
    var date: Date
    var entries: [Journal]
    
    // jounral entry
    init(title: String, cover: UIImage, date: Date, entries: [Journal] = []) {
        self.title = title
        self.date = date
        self.cover = cover
        self.entries = entries
    }
}

class TBR{
    var title: String
    var cover: UIImage
    
    init(title: String, cover: UIImage) {
        self.title = title
        self.cover = cover
    }
}

class DoneBook {
    var title: String
    var cover: UIImage
    var dateDone: Date
    var dateStart: Date
    var rating: Int
    var entries: [Journal]
    
    init(title: String, cover: UIImage, rating:Int, dateDone: Date, dateStart: Date, entries: [Journal] = []) {
        self.title = title
        self.cover = cover
        self.rating = rating
        self.dateStart = dateStart
        self.dateDone = dateDone
        self.entries = entries
    }
}
class HomeVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    
    @IBOutlet weak var currentCV: UICollectionView!
    @IBOutlet weak var TBRCV: UICollectionView!
    @IBOutlet weak var doneCV: UICollectionView!
    
    // Button outlets
    @IBOutlet weak var tbrAddButton: UIButton!
    @IBOutlet weak var addCurrentButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Update theme
        Theme.setTheme(to: self, theme: themeSelector)
        tbrAddButton.backgroundColor = fillColor
        addCurrentButton.backgroundColor = fillColor
        
        // Clear all lists
        currentBookList.removeAll()
        TBRList.removeAll()
        doneBookList.removeAll()
        
        // Set up for Current CV
        currentCV.dataSource = self
        currentCV.delegate = self
        if let layout = currentCV.collectionViewLayout as? UICollectionViewFlowLayout {
                    layout.scrollDirection = .horizontal }
        currentCV.isPagingEnabled = true
        // Import current books from coreData
        let fetchedCurrent = getSavedCurrent()
        for book in fetchedCurrent {
            if let title = book.value(forKey: "title") as? String,
               let date = book.value(forKey: "date") as? Date,
               let cover = book.value(forKey: "cover") as? Data {
                var savedImage = UIImage(data: cover)
                var savedCurrent = CurrentBook(title: title, cover: savedImage!, date: date)
                
                // Retrieve journal entires associated with this book
                if let journalEntries = book.value(forKey: "journal") as? Set<NSManagedObject> {
                    let sortedJournalEntries = journalEntries.sorted {
                        ($0.value(forKey: "date") as! Date) < ($1.value(forKey: "date") as! Date)
                    }
                    
                    for journal in sortedJournalEntries {
                        if let journalContent = journal.value(forKey: "content") as? String,
                           let journalDate = journal.value(forKey: "date") as? Date {
                            let journalEntry = Journal(date: journalDate, content: journalContent)
                            savedCurrent.entries.append(journalEntry)
                        } else {
                            print("Error unwrapping journal attributes")
                        }
                    }
                }
                
                currentBookList.append(savedCurrent)
            } else {
                print("Error unwrapping core data current book attributes")
            }
        }
        
        
        // Set up for TBR CV
        TBRCV.dataSource = self
        TBRCV.delegate = self
        if let layout = TBRCV.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        TBRCV.isPagingEnabled = true
        // import TBR books form core data
        let fetchedTBR = getSavedTBR()
        for book in fetchedTBR {
            if let title = book.value(forKey: "title") as? String,
               let cover = book.value(forKey: "cover") as? Data {
                var savedImage = UIImage(data: cover)
                var savedTBR = TBR(title: title, cover: savedImage!)
                TBRList.append(savedTBR)
            } else {
                print("Error unwrapping core data TBR attributes")
            }
        }
        

        
        // Set up Done VC
        doneCV.delegate = self
        doneCV.dataSource = self
        if let layout = doneCV.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        doneCV.isPagingEnabled = true
        // import done books from core data
        
        let fetchedDone = getSavedDone()
        for book in fetchedDone {
            if let title = book.value(forKey: "title") as? String,
               let doneDate = book.value(forKey: "doneDate") as? Date,
               let startDate = book.value(forKey: "startDate") as? Date,
               let cover = book.value(forKey: "cover") as? Data,
                let rate = book.value(forKey: "rating") as? Int64 {
                var savedImage = UIImage(data: cover)
                var savedDone = DoneBook(title: title, cover: savedImage!, rating: Int(rate), dateDone: doneDate, dateStart: startDate)
                
                // Retrieve journal entires associated with this book
                if let journalEntries = book.value(forKey: "journal") as? Set<NSManagedObject> {
                    let sortedJournalEntries = journalEntries.sorted {
                        ($0.value(forKey: "date") as! Date) < ($1.value(forKey: "date") as! Date)
                    }
                    
                    for journal in sortedJournalEntries {
                        if let journalContent = journal.value(forKey: "content") as? String,
                           let journalDate = journal.value(forKey: "date") as? Date {
                            let journalEntry = Journal(date: journalDate, content: journalContent)
                            savedDone.entries.append(journalEntry)
                        } else {
                            print("Error unwrapping journal attributes")
                        }
                    }
                }
                
                doneBookList.append(savedDone)
            } else {
                print("Error unwrapping core data current book attributes")
            }
        }
        
        // Example Books:
        
        var tbrBookExample = TBR(title: "Throne of Glass", cover: UIImage(named: "TOGCover")!)
        TBRList.append(tbrBookExample)

        var journalExample1 = Journal(date: stringtoDate("12/07/2024")!, content: "This is an example of a journal entry")
        var currentBookExample = CurrentBook(title: "Six of Crows", cover: UIImage(named: "SOCCover")!, date: stringtoDate("12/08/2024")!, entries: [journalExample1])
        currentBookList.append(currentBookExample)
        
        var doneBookExample = DoneBook(title: "The Naturals", cover: UIImage(named: "NaturalsCover")!, rating: 5, dateDone: stringtoDate("12/10/2023")!, dateStart: stringtoDate("11/20/2023")!, entries: [journalExample1])
        doneBookList.append(doneBookExample)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentCV.reloadData()
        TBRCV.reloadData()
        Theme.setTheme(to: self, theme: themeSelector)
        
        tbrAddButton.backgroundColor = fillColor
        addCurrentButton.backgroundColor = fillColor
    }
    
    func getSavedCurrent() -> [NSManagedObject] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedCurrentBook")
        var fetchedResults: [NSManagedObject]?
        
        do {
                try fetchedResults = context.fetch(request) as? [NSManagedObject]
                } catch {
                    print("Error occured while retrieving obejct")
                    return []
                }
                return fetchedResults!
            }
    
    func getSavedTBR() -> [NSManagedObject] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedTBR")
        var fetchedResults: [NSManagedObject]?
        
        do {
                try fetchedResults = context.fetch(request) as? [NSManagedObject]
                } catch {
                    print("Error occured while retrieving obejct")
                    return []
                }
                return fetchedResults!
            }
    
    func getSavedDone() -> [NSManagedObject] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedDoneBook")
        var fetchedResults: [NSManagedObject]?
        do {
                try fetchedResults = context.fetch(request) as? [NSManagedObject]
                } catch {
                    print("Error occured while retrieving obejct")
                    return []
                }
                return fetchedResults!
            }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == currentCV {
            return currentBookList.count
        } else if collectionView == TBRCV {
            return TBRList.count
        } else {
            return doneBookList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == currentCV {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath) as! BookCVCell2
            let book = currentBookList[indexPath.row]
            cell.coverImage.image = book.cover
            return cell
        } else if collectionView == TBRCV {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath) as! TBRCollectionViewCell
            let book = TBRList[indexPath.row]
            cell.coverImage.image = book.cover
            return cell
        } else if collectionView == doneCV {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath) as! DoneBookCell
            let book = doneBookList[indexPath.row]
            cell.coverImage.image = book.cover
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == currentCV {
            return CGSize(width: 150.0, height: 255.0)
        } else if collectionView == TBRCV {
            return CGSize(width: 150.0, height: 255.0)
        }
        return CGSize(width: 150.0, height: 255.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == currentCV {
            // Save the selected book and perform segue
            let selectedBook = currentBookList[indexPath.row]
            performSegue(withIdentifier: "CurrentBookSegue", sender: selectedBook)
        } else if collectionView == TBRCV {
            let selectedBook = TBRList[indexPath.row]
            performSegue(withIdentifier: "TBRSegue", sender: selectedBook)
        } else if collectionView == doneCV {
            let selectedBook = doneBookList[indexPath.row]
            performSegue(withIdentifier: "doneBookSegue", sender: selectedBook)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CurrentBookSegue" {
            if let destinationVC = segue.destination as? CurrentBookVC,
               let selectedBook = sender as? CurrentBook {
                destinationVC.book = selectedBook
            }
        } else if segue.identifier == "TBRSegue" {
            if let destinationVC = segue.destination as? TBRBookVC,
               let selectedBook = sender as? TBR {
                destinationVC.book = selectedBook
            }
        } else if segue.identifier == "doneBookSegue" {
                if let destinationVC = segue.destination as? DoneBookVC,
                   let selectedBook = sender as? DoneBook {
                    destinationVC.book = selectedBook
                }
            }
        }
    
    func stringtoDate(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        return dateFormatter.date(from: dateString)
    }
}
