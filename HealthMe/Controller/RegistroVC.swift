//
//  RegistroVC.swift
//  HealthMe
//
//  Created by Luis Isaac Maya on 11/7/18.
//  Copyright © 2018 Luis Isaac Maya. All rights reserved.
//

import UIKit
import Firebase

class RegistroVC: UIViewController {
    
    
    @IBOutlet weak var Correo: UITextField!
    @IBOutlet weak var Contraseña: UITextField!
    @IBOutlet weak var CodigoNutriologo: UITextField!
    let db = Firestore.firestore()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    
    //MARK: Quitar teclado
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    
    
    @IBAction func Registrar(_ sender: UIButton) {
        
        Auth.auth().createUser(withEmail: Correo.text!, password: Contraseña.text!) { (DataResult, Error) in
            
            if Error != nil{
                
                if Error!.localizedDescription == "The email address is already in use by another account."{
                    
                    let alert = UIAlertController(title: "Error al registrar", message: "El e-mail ya esta en uso", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    
                    self.present(alert, animated: true)
                }
                
                let alert = UIAlertController(title: "Error al registrar", message: "No ingresaste un correo o tu contraseña tiene menos de 6caracteres", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    
                    self.present(alert, animated: true)
            }
            else{
                
                
                //Se guardo el usuario
                print("Registration Complete")
                
                let usuarioActual = Auth.auth().currentUser
                
                // Add a new document with a generated ID
                var ref: DocumentReference? = nil
                ref = self.db.collection("users").addDocument(data: [
                    "Nombre": "Prueba",
                    "Apellido": "CloduFirestore",
                    "UserID": usuarioActual!.uid
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("Document added with ID: \(ref!.documentID)")
                        self.performSegue(withIdentifier: "gotoDashBoard2", sender: self)
                    }
                }
                
                
                
            }
            
        }
        
    }
    
  

}
