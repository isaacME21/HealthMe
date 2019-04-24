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
        
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showPlan),
                                               name: NSNotification.Name("gotoPlan"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showCitas),
                                               name: NSNotification.Name("gotoCitas"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showSocial),
                                               name: NSNotification.Name("gotoSocial"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showHealth),
                                               name: NSNotification.Name("gotoHealth"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showAchievements),
                                               name: NSNotification.Name("gotoAchievements"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showChat),
                                               name: NSNotification.Name("gotoChat"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showAvatar),
                                               name: NSNotification.Name("gotoAvatar"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showConfiguracion),
                                               name: NSNotification.Name("gotoConfiguracion"),
                                               object: nil)


        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        db.collection("Pacientes").document(Auth.auth().currentUser!.email!).getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                print("Document data: \(String(describing: dataDescription))")
                let defaults = UserDefaults.standard
                let nutriologo = dataDescription!["nutriologo"] as? String
                let talla = dataDescription!["talla"] as? Double
                let edad = dataDescription!["edad"] as? Double
                defaults.set(nutriologo!, forKey: "Nutriologo")
                defaults.set(talla, forKey: "talla")
                defaults.set(edad, forKey: "edad")
            } else {
                print("Document does not exist")
            }
        }
    }
    
    
    
    @IBAction func LogOut(_ sender: UIBarButtonItem) {
        do{
            try Auth.auth().signOut()
            dismiss(animated: true, completion: nil)
        }
        catch{
            print("Error al cerrar sesion")
        }
        
    }
    @IBAction func showMenu(_ sender: UIBarButtonItem) {
        NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"), object: nil)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        NotificationCenter.default.post(name: NSNotification.Name("HideSideMenu"), object: nil)
    }
    
    @objc func showPlan(){
         performSegue(withIdentifier: "gotoPlan", sender: nil)
    }
    @objc func showCitas(){
         performSegue(withIdentifier: "gotoCitas", sender: nil)
    }
    @objc func showSocial(){
         performSegue(withIdentifier: "gotoSocial", sender: nil)
    }
    @objc func showHealth(){
         performSegue(withIdentifier: "gotoHealth", sender: nil)
    }
    @objc func showAchievements(){
         performSegue(withIdentifier: "gotoAchievements", sender: nil)
    }
    @objc func showChat(){
         performSegue(withIdentifier: "gotoChat", sender: nil)
    }
    @objc func showAvatar(){
         performSegue(withIdentifier: "gotoAvatar", sender: nil)
    }
    @objc func showConfiguracion(){
         performSegue(withIdentifier: "gotoConfiguracion", sender: nil)
    }
    

}
