//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    
    
    // Mesajlarin saklanacagi array
    var messageArray : [Message] = [Message]()
    
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        messageTextfield.delegate = self
        
        //Set the tapGesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        

        //TODO: Register your MessageCell.xib file here:
        // bundle bos cunku xcode kendi bulsun dosyayi yol belirtmeye gerek yoks
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        configureTableView()
        retrieveMessages()
        
        //tableview cizgilerini kaldir
        messageTableView.separatorStyle = .none
    }

    ///////////////////////////////////////////
    //MARK: - TableView DataSource Methods
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //cell yapisini belirleyelim. customMessageCell = MessageCell.xib identifier'i
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        // UI'i guncelliyoruz
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named: "egg")
        
        if cell.senderUsername.text == Auth.auth().currentUser?.email as String! {
            cell.avatarImageView.backgroundColor = UIColor.flatMint()
            cell.messageBackground.backgroundColor = UIColor.flatSkyBlue()
        } else {
            cell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
            cell.messageBackground.backgroundColor = UIColor.flatGray()
        }
        
        return cell
    }
    
    
    //TODO: Declare numberOfRowsInSection here:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    
    //TODO: Declare tableViewTapped here:
    @objc func tableViewTapped() {
        messageTextfield.endEditing(true)
    }
    
    
    //TODO: Declare configureTableView here:
    //Cell'in mesajin uzunluguna gore kendiliginden buyumesi gerekiyor
    func configureTableView() {
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 120.0
        tableViewScrollToBottom(animated: false)
    }
    
    
    ///////////////////////////////////////////
    //MARK:- TextField Delegate Methods
    //Klavye 258 piksel, texfieldin bulundugu cubuk 50 piksel = 308 piksel
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        //textfield yukari cikarken kayma animasyonu ekleyelim
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 308
            self.tableViewScrollToBottom(animated: true)
            //view icerisinde constraint veya herhangi birsey degistiginde herseyi tekrar ciz
            self.view.layoutIfNeeded()
        }
    }
    
    
    
    // Configure Text Field
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 50
            //view icerisinde constraint veya herhangi birsey degistiginde herseyi tekrar ciz
            self.view.layoutIfNeeded()
        }
    }

    
    ///////////////////////////////////////////
    //MARK: - Send & Recieve from Firebase
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        
        //TODO: Send the message to Firebase and save it in our database
        messageTextfield.endEditing(true)
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        let messagesDB = Database.database().reference().child("Messages")
        let messageDictionary = ["Sender": Auth.auth().currentUser?.email,
                                 "MessageBody": messageTextfield.text!]
        //mesajlar icin unique id olusturuyiruz ki her birinin kendine ozgu identifier'i olsun
        messagesDB.childByAutoId().setValue(messageDictionary) { (error, mahmut) in
            if error != nil {
                print(error!)
            } else {
                print ("Message saved succesfully")
                self.messageTextfield.isEnabled = true
                
                //
                self.sendButton.isEnabled = true
                
                //Yazilan mesaji temizle
                self.messageTextfield.text = ""
            }
        }
    }
    
    //TODO: Create the retrieveMessages method here:
    func retrieveMessages() {
        // Izleyecegimiz database'i belirleyelim
        let messageDB = Database.database().reference().child("Messages")
        // database'i izleyelim. childAdded = yeni child node eklendi demek
        messageDB.observe(.childAdded) { (snapshot) in
            // Simdi izlenen veritabaninin o anki goruntusunden(snapshot) veriyi alip custom message object formatina sokacagiz. Kendi type'i Any? iken biz dictionary ye ceviriyoruz. Dictionary, messageDictionary ile ayni tipte olmali yani String ve String
            let snapShotValue = snapshot.value as! Dictionary<String, String>
            //Veriyi cektik. Simdi kullanalim
            let text = snapShotValue["MessageBody"]!
            let sender = snapShotValue["Sender"]!
            print(text, sender)
            
            let message = Message()
            message.messageBody = text
            message.sender = sender
            
            self.messageArray.append(message)
            
            // yeni mesaj(data) alindigi icin tableView formatini yeniden duzenlemek gerekiyor
            self.configureTableView()
            // tableview'daki veriyi yenileyelim
            self.messageTableView.reloadData()
        }
    }
    

    // MARK: Logout
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        do {
            try Auth.auth().signOut()
            //Tekrar basa donmek icin navigation controller'i kullaniyoruz
            navigationController?.popToRootViewController(animated: true)
        } catch {
            print("There was a problem while signing out")
        }
    }
    
    func tableViewScrollToBottom(animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            let numberOfSections = self.messageTableView.numberOfSections
            let numberOfRows = self.messageTableView.numberOfRows(inSection: numberOfSections-1)
            
            if numberOfRows > 0 {
                let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                self.messageTableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
            }
        }
    }
}
