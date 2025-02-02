//
//  CollectionViewHeader.swift
//  Bookworm
//
//  Created by Sathyashri.Muruganandam on 2024-11-16.
//

import UIKit

class CollectionViewHeader: UICollectionReusableView {
        
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    func configure(with title: String) {
        headerLabel.text = title
    }
}
