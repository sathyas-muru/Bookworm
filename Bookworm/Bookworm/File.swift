//
//  File.swift
//  Bookworm
//
//  Created by Sathyashri.Muruganandam on 2024-11-17.
//

import Foundation
import UIKit

let beigeColor = UIColor(red: 249/255, green: 220/255, blue: 144/255, alpha: 1)
let aqua = UIColor(red: 164/255, green: 254/255, blue: 236/255, alpha: 1)
let redColor = UIColor(red: 255/255, green: 20/255, blue: 0/255, alpha: 1)

var backgroundColor: UIColor = .black
var textColor: UIColor = .black
var fillColor: UIColor = .cyan
var bubbleColor: UIColor = .systemGray5
var bubbleTextColor: UIColor = .black


func saveTheme(_ theme: Theme) {
    UserDefaults.standard.set(theme.rawValue, forKey: "slectedThemeIndex")
    UserDefaults.standard.synchronize()
}

// Load theme variable from usersdefaults
func loadSavedTheme() -> Theme {
    if let savedTheme = UserDefaults.standard.string(forKey: "selectedThemeIndex"),
           let theme = Theme(rawValue: Int(savedTheme) ?? 0) {
            return theme
        }
        return .classic
}

enum Theme: Int {
    case classic = 0, light, dark
}

extension Theme {
    
    static func setTheme(to viewController: UIViewController, theme: Theme) {
        switch theme {
        case .classic:
            setClassicTheme(to: viewController)
        case .light:
            setLightTheme(to: viewController)
        case .dark:
            setDarkTheme(to: viewController)
        }
    }
    
    private static func setClassicTheme(to viewController: UIViewController) {
        
        viewController.view.backgroundColor = beigeColor
        UILabel.appearance().textColor = .black
        
        // set button appearance
        UIButton.appearance().setTitleColor(.black, for: .normal)
        UIButton.appearance().tintColor = .black
        UIButton.appearance().layer.cornerRadius = 20
        UIButton.appearance().clipsToBounds = true
        
        // change background color for filled buttons
        // UIButton.appearance().backgroundColor = aqua
        UITextField.appearance()
        
        // set Nav/Tab bar color
        UINavigationBar.appearance().barTintColor = .white
        UINavigationBar.appearance().tintColor = .black

        // UITabBar.appearance().unselectedItemTintColor = .darkGray
        // UITabBar.appearance().backgroundColor = .white
        // UINavigationBar.appearance().backgroundColor = aqua
        
        // Background color of other views
        UICollectionView.appearance().backgroundColor = beigeColor
        UITableView.appearance().backgroundColor = beigeColor
        UIDatePicker.appearance().overrideUserInterfaceStyle = .light
        UIPickerView.appearance().overrideUserInterfaceStyle = .light
    }
    
    private static func setLightTheme(to viewController: UIViewController) {
        viewController.view.backgroundColor = .white
        UILabel.appearance().textColor = .black
        UIButton.appearance().setTitleColor(.black, for: .normal)
        UIButton.appearance().tintColor = .black
        UIButton.appearance().layer.cornerRadius = 20
        UIButton.appearance().clipsToBounds = true
        // UIButton.appearance().backgroundColor = aqua
        UITextField.appearance()
        
        // set Navigaton bar color
        UINavigationBar.appearance().barTintColor = .gray
        UINavigationBar.appearance().tintColor = .black
        // UITabBar.appearance().selectedImageTintColor = .cyan
        // UITabBar.appearance().unselectedItemTintColor = .darkGray
        // UITabBar.appearance().backgroundColor = .systemGray4
        
        // UINavigationBar.appearance().backgroundColor = aqua
        UICollectionView.appearance().backgroundColor = .white
        UITableView.appearance().backgroundColor = .white
        UIDatePicker.appearance().overrideUserInterfaceStyle = .light
        UIPickerView.appearance().overrideUserInterfaceStyle = .light
    }
    
    private static func setDarkTheme(to viewController: UIViewController) {
        viewController.view.backgroundColor = .black
        UILabel.appearance().textColor = .white
        UIButton.appearance().setTitleColor(.white, for: .normal)
        UIButton.appearance().tintColor = .white
        UIButton.appearance().layer.cornerRadius = 20
        UIButton.appearance().clipsToBounds = true
        // UIButton.appearance().backgroundColor = redColor
        UITextField.appearance()
        
        UIDatePicker.appearance().tintColor = .black
        UIDatePicker.appearance().backgroundColor = redColor
        UIPickerView.appearance().backgroundColor = bubbleColor
        UIPickerView.appearance().tintColor = .black
        // UIDatePicker.appearance().overrideUserInterfaceStyle = .dark
        
        // set Navigaton bar color
        UINavigationBar.appearance().barTintColor = .white
        UINavigationBar.appearance().tintColor = .white
        // UITabBar.appearance().selectedImageTintColor = .cyan
        // UITabBar.appearance().unselectedItemTintColor = .white
        // UITabBar.appearance().backgroundColor = .darkGray
        UICollectionView.appearance().backgroundColor = .black
        UITableView.appearance().backgroundColor = .black
        
        // viewController.navigationController?.navigationBar.setNeedsLayout()
    }
}

