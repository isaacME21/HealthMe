//
//  ViewController.swift
//  HealthMe
//
//  Created by Luis Isaac Maya on 11/6/18.
//  Copyright © 2018 Luis Isaac Maya. All rights reserved.
//

import UIKit
import Firebase

class LogInVC: UIViewController {
    
    @IBOutlet weak var Correo: UITextField!
    @IBOutlet weak var Contraseña: UITextField!
    

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
    
    
    
    
    @IBAction func LogIn(_ sender: UIButton) {
        
        Auth.auth().signIn(withEmail: Correo.text!, password: Contraseña.text!) { (DataResult, error) in
            
            if error != nil{
                print(error!)
                
                let alert = UIAlertController(title: "Error de Inicio de Sesion", message: "Lo sentimos, el usuario o la contraseña son incorrectos", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    
                    self.present(alert, animated: true)
            }
            else{
                //Logeo exitoso
                
                self.performSegue(withIdentifier: "gotoDashBoard", sender: self)
            }
        }
        
    }
    
    
    
    
    
    
    
    
    @IBAction func RegistroNuevo(_ sender: UIButton) {
        performSegue(withIdentifier: "gotoRegistro", sender: self)
    }
    

}

