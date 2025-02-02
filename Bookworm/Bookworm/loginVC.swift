//
//  loginVC.swift
//  Bookworm
//
//  Created by Sathyashri.Muruganandam on 2024-11-10.
//

import UIKit
import FirebaseAuth

class loginVC: UIViewController {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    
    // button outletrs
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // themeSelector = loadSavedTheme()
        Theme.setTheme(to: self, theme: themeSelector)
        signInButton.backgroundColor = fillColor
        createAccountButton.backgroundColor = fillColor
        
        // Do any additional setup after loading the view.
        Auth.auth().addStateDidChangeListener() {
                    (auth,user) in
                    if user != nil {
                        self.performSegue(withIdentifier: "loginSegue", sender: nil)
                        self.username.text = nil
                        self.password.text = nil
                    }
                }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Theme.setTheme(to: self, theme: themeSelector)
        signInButton.backgroundColor = fillColor
        createAccountButton.backgroundColor = fillColor
    }
    
    @IBAction func loginButton(_ sender: Any) {
        Auth.auth().signIn(withEmail:username.text!, password:password.text!) {
            (authResult, error) in
            if let error = error as NSError? {
                self.errorMessage.text = "\(error.localizedDescription)"
            } else {
                self.errorMessage.text = ""
                self.performSegue(withIdentifier: "loginSegue", sender: nil)            }
        }
    }
    
    @IBAction func createAccountButton(_ sender: Any) {
        errorMessage.text = ""
        let alert = UIAlertController(
                   title: "Create Account", message: "create an account", preferredStyle: .alert
               )
               
               alert.addTextField() { tfEmail in
                   tfEmail.placeholder = "Enter your email"}
               alert.addTextField() {tfPassword in tfPassword.placeholder = "Enter your password"}
        let saveAction  = UIAlertAction(title: "Save", style: .default) {_ in
            let emailFields = alert.textFields![0]
            let passwordFields = alert.textFields![1]
            
            // create user here
            Auth.auth().createUser(withEmail: emailFields.text!, password: passwordFields.text!) {
                (authResult, error) in
                if let error = error as NSError? {
                    self.errorMessage.text = "\(error.localizedDescription)"
                } else {
                    self.errorMessage.text = ""
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
              alert.addAction(saveAction)
              alert.addAction(cancelAction)
              present(alert, animated: true)
    }
}
