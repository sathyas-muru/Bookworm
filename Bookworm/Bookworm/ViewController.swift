//
//  ViewController.swift
//  Bookworm
//
//  Created by Sathyashri.Muruganandam on 2024-10-30.
//

import UIKit

/*

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var TBRCV: UICollectionView!
    @IBOutlet weak var doneBookCV: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Theme.setTheme(to: self, theme: themeSelector)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        TBRCV.delegate = self
        TBRCV.dataSource = self
        doneBookCV.delegate = self
        doneBookCV.dataSource = self
        
        // generating example books
        var tbrBookExample = TBR(title: "Throne of Glass", cover: UIImage(named: "TOGCover")!)
        TBRList.append(tbrBookExample)
        
        var currentBookExample = CurrentBook(title: "Six of Crows",  cover: UIImage(named: "SOCCover")!, date: stringtoDate("11/12/2024")!)
        currentBookList.append(currentBookExample)
        
        var finishedBookExample = DoneBook(title: "The Naturals", cover: UIImage(named: "NaturalsCover")!, rating: 5, dateDone: stringtoDate("12/10/2023")!, dateStart: stringtoDate("12/09/2023")!)
        doneBookList.append(finishedBookExample)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == TBRCV {
            return TBRList.count
        } else if collectionView == doneBookCV {
            return doneBookList.count
        } else {
            return currentBookList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == TBRCV {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TBRCell", for: indexPath) as! TBRCollectionViewCell
            let book = TBRList[indexPath.row]
            cell.coverImage.image = book.cover
            return cell
        } else if collectionView  == doneBookCV {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DoneCell", for: indexPath) as! DoneBookCollectionViewCell
            let book = doneBookList[indexPath.row]
            cell.coverImage.image = book.cover
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath) as! BookCollectionViewCell
            let book = currentBookList[indexPath.row]
            cell.coverImage.image = book.cover
            return cell
        }
    }
    
    /*
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as! CollectionViewHeader
        
        switch indexPath.section {
        case 0:
            header.configure(with: "Currently Reading")
        case 1:
            header.configure(with: "TBR")
        case 2:
            header.configure(with: "Finished Books")
        default:
            print("Unknown section selected")
        }
        return header
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath) as! BookCollectionViewCell
        
        switch indexPath.section {
        case 1:
            let book = TBRList[indexPath.row]
            cell.coverImage.image = book.cover
        case 0:
            let book = currentBookList[indexPath.row]
            cell.coverImage.image = book.cover
        case 2:
            let book = doneBookList[indexPath.row]
            cell.coverImage.image = book.cover
        default:
            print("Unknown section selected")
        }
    
        return cell
    } */
    
    func stringtoDate(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy" // Specify your date format
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        return dateFormatter.date(from: dateString)
    }
} */
