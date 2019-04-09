//
//  DashBoardVC.swift
//  HealthMe
//
//  Created by Luis Isaac Maya on 11/7/18.
//  Copyright © 2018 Luis Isaac Maya. All rights reserved.
//

import UIKit
import Firebase

class DashBoardVC: UIViewController {
    
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        let user = Auth.auth().currentUser
        
        if let user = user {
         
            let uid = user.uid
            let email = user.email
            let photoURL = user.photoURL
            let displayName = user.displayName
            
            print(uid)
            print(email as Any)
            print(displayName as Any)
            print(photoURL as Any)
        }

        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        db.collection("Pacientes").document(Auth.auth().currentUser!.email!).getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                print("Document data: \(String(describing: dataDescription))")
                let defaults = UserDefaults.standard
                let nutriologo = dataDescription!["nutriologo"] as? String
                defaults.set(nutriologo!, forKey: "Nutriologo")
            } else {
                print("Document does not exist")
            }
        }
    }
    
    
    
    @IBAction func LogOut(_ sender: UIBarButtonItem) {
        do{
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        }
        catch{
            print("Error al cerrar sesion")
        }
        
    }
    

}
