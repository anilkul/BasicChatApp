//
//  LogInViewController.swift
//  Flash Chat
//
//  This is the view controller where users login


import UIKit
import Firebase
import SVProgressHUD

class LogInViewController: UIViewController {

    //Textfields pre-linked with IBOutlets
    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: Login
    @IBAction func logInPressed(_ sender: AnyObject) {

        SVProgressHUD.show()
        // Login the user
        Auth.auth().signIn(withEmail: emailTextfield.text!, password: passwordTextfield.text!) { (user, error) in
            if error != nil{
                print(error!)
            } else {
                print("Login Succesful")
                SVProgressHUD.dismiss()
                //closure icinde oldugumuzdan fonkiyonu cagirirken self. kullaniyoruz
                self.performSegue(withIdentifier: "goToChat", sender: self)
            }
        }
        
    }
    


    
}  
