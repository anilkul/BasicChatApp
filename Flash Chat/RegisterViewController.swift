//
//  RegisterViewController.swift
//  Flash Chat
//
//  This is the View Controller which registers new users with Firebase
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {

    
    //Pre-linked IBOutlets

    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    // MARK: Register
    @IBAction func registerPressed(_ sender: AnyObject) {

        let email = emailTextfield.text
        let password = passwordTextfield.text
        
        // Create User
        Auth.auth().createUser(withEmail: email!, password: password!) {
            (user, error) in
            if error != nil{
                print(error!)
            } else {
                print("Registration Succesful")
                //closure icinde oldugumuzdan fonkiyonu cagirirken self. kullaniyoruz
                self.performSegue(withIdentifier: "goToChat", sender: self)
            }
        }
        
        

        
    } 
    
    
}
