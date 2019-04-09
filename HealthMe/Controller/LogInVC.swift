//
//  ViewController.swift
//  HealthMe
//
//  Created by Luis Isaac Maya on 11/6/18.
//  Copyright © 2018 Luis Isaac Maya. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class LogInVC: UIViewController {
    
    @IBOutlet weak var Correo: UITextField!
    @IBOutlet weak var Contraseña: UITextField!
    @IBOutlet weak var Nutriologo: UITextField!
    
    lazy var db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
 
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
 
    }
    
    //MARK: Quitar teclado
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    
    
    
    @IBAction func LogIn(_ sender: UIButton) {
        let correo = Correo.text!
        SVProgressHUD.show()
        DispatchQueue.global().async {
            self.db.collection("Nutriologos").document(correo).getDocument { (document, error) in
                if let document = document, document.exists {
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    print("Document data: \(dataDescription)")
                    SVProgressHUD.dismiss()
                    return
                } else {
                    print("Document does not exist")
                    self.firebaseLogIn()
                }
            }
        }
    }
    
    func firebaseLogIn() {
        let correo = Correo.text!
        let contraseña = Contraseña.text!
        Auth.auth().signIn(withEmail: correo, password: contraseña) { (DataResult, error) in
            
            if error != nil{
                print(error!)
                
                let alert = UIAlertController(title: "Error de Inicio de Sesion", message: "Lo sentimos, el usuario o la contraseña son incorrectos", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.present(alert, animated: true)
                }
                
            }
            else{
                //Logeo exitoso
                SVProgressHUD.dismiss()
                self.performSegue(withIdentifier: "gotoDashBoard", sender: self)
            }
        }
    }
    
    

    

}

