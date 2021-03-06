//
//  LoginViewController.swift
//  CarFinder
//
//  Created by alexander boswell on 5/3/17.
//  Copyright © 2017 alexander boswell. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: UI Elements
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: Overriden functions
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.emailTextField.delegate = self 
        self.passwordTextField.delegate = self
        // set up tap to close keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let _ = FIRAuth.auth()?.currentUser {
            self.signIn()
        }
    }
    
    // MARK: UI Actions
    @IBAction func signIn(_ sender: UIButton) {
        dismissKeyboard()
        let email = emailTextField.text
        let password = passwordTextField.text
        if email == "" {
            self.showAlert("Please enter a email")
        } else if password == "" {
            self.showAlert("Please enter a password ")
        } else {
            self.loginUser( email: email!, password: password!)
        }
    }
    func loginUser(email: String, password: String){
        present(LoadingOverlay.instance.showLoadingOverlay(message: "Logging in..."), animated: true, completion: nil)
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: {(user, error) in
            guard let _ = user else {
                if let error = error {
                    if let errCode = FIRAuthErrorCode(rawValue: error._code) {
                        self.dismiss(animated: false, completion: { (dissmissOverlayError) in
                            switch errCode {
                            case .errorCodeUserNotFound:
                                self.showAlert("User account not found. Try registering")
                            case .errorCodeWrongPassword:
                                self.showAlert("Incorrect username/password combination")
                            default:
                                self.showAlert("Error: \(error.localizedDescription)")
                            }
                        })
                        return
                    }
                }
                assertionFailure("user and error are nil")
                return
            }
            self.dismiss(animated: false, completion: { (error) in
                self.signIn()
            })
        })
    }
    @IBAction func forgotPassword(_ sender: UIButton) {
        let prompt = UIAlertController(title: "Spot It", message: "Email:", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            let userInput = prompt.textFields![0].text
            if (userInput!.isEmpty) {
                return
            }
            FIRAuth.auth()?.sendPasswordReset(withEmail: userInput!, completion: { (error) in
                if let error = error {
                    if let errCode = FIRAuthErrorCode(rawValue: error._code) {
                        switch errCode {
                        case .errorCodeUserNotFound:
                            DispatchQueue.main.async {
                                self.showAlert("User account not found. Try registering")
                            }
                        default:
                            DispatchQueue.main.async {
                                self.showAlert("Error: \(error.localizedDescription)")
                            }
                        }
                    }
                    return
                } else {
                    DispatchQueue.main.async {
                        self.showAlert("You'll receive an email shortly to reset your password.")
                    }
                }
            })
        }
        prompt.addTextField(configurationHandler: nil)
        prompt.addAction(okAction)
        present(prompt, animated: true, completion: nil)
    }
    
    // MARK: Other functions
    func showAlert(_ message: String) {
        let alertController = UIAlertController(title: "Spot It", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func signIn() {
        performSegue(withIdentifier: "LoginToMainView", sender: nil)
        passwordTextField.text = ""
        emailTextField.text = ""
        FireBaseDataObject.system.getCurrentUser { (User) in
            UIImageView().loadImageUsingCacheWithURLString(urlString: User.profileImageURL)
        }
            
    }
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
                nextField.becomeFirstResponder()
        } else {
        self.signIn(UIButton())
        }
        return true
    }
}
