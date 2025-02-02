//
//  SettingsVC.swift
//  Bookworm
//
//  Created by Sathyashri.Muruganandam on 2024-11-12.
//

import UIKit
import FirebaseAuth

class SettingsVC: UIViewController {
    
    @IBOutlet weak var segCntrl: UISegmentedControl!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var settingsLabel: UILabel!
    @IBOutlet weak var selectThemeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Theme.setTheme(to: self, theme: themeSelector)
        segCntrl.selectedSegmentIndex = themeSelector.rawValue
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Theme.setTheme(to: self, theme: themeSelector)
        logoutButton.backgroundColor = fillColor
        
        if segCntrl.selectedSegmentIndex == 2 {
            segCntrl.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        }
    }
    
    @IBAction func onSegmentChanged(_ sender: Any) {
        switch segCntrl.selectedSegmentIndex {
        case 0:
            themeSelector = .classic
            backgroundColor = beigeColor
            textColor = .black
            fillColor = aqua
            bubbleColor = .lightGray
            
            segCntrl.subviews[1].backgroundColor = .systemGray
            segCntrl.subviews[2].backgroundColor = .systemGray
            
            
        case 1:
            themeSelector = .light
            backgroundColor = .white
            textColor = .black
            fillColor = aqua
            bubbleColor = .systemGray5
            
            segCntrl.subviews[0].backgroundColor = .systemGray
            segCntrl.subviews[2].backgroundColor = .systemGray
            
        case 2:
            themeSelector = .dark
            backgroundColor = .black
            textColor = .white
            fillColor = redColor
            bubbleColor = .white
            
            segCntrl.subviews[0].backgroundColor = .lightGray
            segCntrl.subviews[1].backgroundColor = .lightGray
            
        default:
            themeSelector = .classic
        }
        saveTheme(themeSelector)

        
        Theme.setTheme(to: self, theme: themeSelector)
        segCntrl.selectedSegmentIndex = themeSelector.rawValue
        logoutButton.backgroundColor = fillColor
        settingsLabel.textColor = textColor
        selectThemeLabel.textColor = textColor
        segCntrl.backgroundColor = backgroundColor
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: textColor], for: .normal)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: textColor], for: .selected)}

        @IBAction func logoutButton(_ sender: Any) {
            do {
                try Auth.auth().signOut()
                self.dismiss(animated: true)
            } catch {
                print("Sign out eror")
            }
            
        }
    // save theme to use defaults
    
    }
