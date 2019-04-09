//
//  ChatVC.swift
//  HealthMe
//
//  Created by Luis Isaac Maya on 11/26/18.
//  Copyright © 2018 Luis Isaac Maya. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework


class ChatVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
   

    
    @IBOutlet weak var heightConstrain: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var messageTableView: UITableView!
    
    var messageArray : [Message] = []

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil) , forCellReuseIdentifier: "customMessageCell")
        messageTableView.register(UINib(nibName: "SenderCell", bundle: nil) , forCellReuseIdentifier: "customMessageCell2")
        
        messageTextField.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector (tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        messageTableView.separatorStyle = .none
        
        
        configureTableView()
        retrieveMessages()

    }
    
    
    //MARK: - TableView Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let sender = messageArray[indexPath.row].sender
        
        if sender == Auth.auth().currentUser?.email!{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell2", for: indexPath) as! SenderCustomCell
            cell.messageBody.text = messageArray[indexPath.row].messageBody
            cell.senderUsername.text = messageArray[indexPath.row].sender
            cell.avatarImageView.image = UIImage(named: "egg.png")
            cell.avatarImageView.backgroundColor = UIColor.flatMint()
            cell.messageBackground.backgroundColor = UIColor.flatBlue()
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
            cell.messageBody.text = messageArray[indexPath.row].messageBody
            cell.senderUsername.text = messageArray[indexPath.row].sender
            cell.avatarImageView.image = UIImage(named: "doctor")
            cell.avatarImageView.backgroundColor = UIColor.flatWhite()
            cell.messageBackground.backgroundColor = UIColor.flatGray()
            return cell
            
        }
    
    }
    
    
    //MARK: - TextField Delegate Methods
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstrain.constant = 308
            //self.scrollToBottom()
            self.view.layoutIfNeeded()
        }
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstrain.constant = 50
            self.view.layoutIfNeeded()
        }
    }

    
    
    func configureTableView(){
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    @objc func tableViewTapped() {
        messageTextField.endEditing(true)
    }
    
    func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.messageArray.count-1, section: 0)
            self.messageTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    
    
    
    ///////////////////////////////////////////////////////////////////////
    @IBAction func Salir(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        let date = Date()
        let user = Auth.auth().currentUser!.email!
        
        messageTextField.endEditing(true)
        messageTextField.isEnabled = false
        sendButton.isEnabled = false
        
        let messageDB = Firestore.firestore()
        
        let messageDictionary : [String : Any] = ["Sender": Auth.auth().currentUser!.email!,
                                                  "MessageBody": messageTextField.text!,
                                                  "CreatedTime": date]
        
//        let messageDictionary : [String : Any] = ["Sender": Auth.auth().currentUser!.email!,
//                                                  "MessageBody": messageTextField.text!]
        
        messageDB.collection("Pacientes").document(user).collection("Messages").addDocument(data: messageDictionary){ err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        
        self.messageTextField.isEnabled = true
        self.sendButton.isEnabled = true
        self.messageTextField.text = ""
        
        
    }
    
    func retrieveMessages(){
        let messageDB = Firestore.firestore()
        let user = Auth.auth().currentUser!.email!
        
        let messageRef = messageDB.collection("Pacientes").document(user).collection("Messages")
        
        
        messageRef.addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.messageArray.removeAll()
                for document in querySnapshot!.documents {
                    
                    //print("\(document.documentID) => \(document.data())")
                    let doc = document.data()
                    let message = Message()
                    let timestap = doc["CreatedTime"] as! Timestamp
                    message.messageBody = doc["MessageBody"] as! String
                    message.sender = doc["Sender"] as! String
                    message.date = timestap.dateValue()
                    
                    self.messageArray.append(message)
                }
                let ready = self.messageArray.sorted(by: { $0.date < $1.date })
                self.messageArray = ready
                
                self.configureTableView()
                self.messageTableView.reloadData()
                //self.scrollToBottom()
            }
        }
        
    }
    
    
    
   

}
