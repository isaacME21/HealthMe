//
//  AvatarVC.swift
//  HealthMe
//
//  Created by Luis Isaac Maya on 11/26/18.
//  Copyright © 2018 Luis Isaac Maya. All rights reserved.
//

import UIKit
import Firebase

class AvatarVC: UIViewController {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var edadTextField: UITextField!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        avatarImageView.loadGif(name: "pruebaGif")
    }
    
    
    @IBAction func guardarAction(_ sender: UIButton) {
        saveFB()
    }
    
    
    @IBAction func Salir(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    //FIREBASE METHOD
    func saveFB()  {
        let nombre = nombreTextField.text
        let userName = displayNameTextField.text
        let edad = edadTextField.text
        db.collection("Pacientes").document(Auth.auth().currentUser!.email!).updateData(
            ["Nombre" : nombre!,
             "UserName" : userName!,
             "Edad" : edad!]){ err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                    self.changeDisplayName(displayName: userName!)
                    self.nombreTextField.text?.removeAll()
                    self.displayNameTextField.text?.removeAll()
                    self.edadTextField.text?.removeAll()
                    
                }
        }
    }
    
    //FIREBASE DISPLAYNAME
    func changeDisplayName(displayName : String){
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = displayName
        changeRequest?.commitChanges { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }

}
