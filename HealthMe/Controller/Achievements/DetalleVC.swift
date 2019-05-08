//
//  DetalleVC.swift
//  HealthMe
//
//  Created by Luis Isaac Maya on 11/26/18.
//  Copyright © 2018 Luis Isaac Maya. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class DetalleVC: UIViewController {
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var IDLabel: UILabel!
    @IBOutlet weak var fechaLabel: UILabel!
    
    
    var detalle = ""
    var imagePath : String?{
        didSet{
            loadInfo()
        }
    }
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale(identifier: "es_MX")
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter
    }()
    
    
    let paciente = Auth.auth().currentUser?.email
    let doctor = Auth.auth().currentUser?.displayName
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    func loadInfo()  {
        db.collection("Pacientes").document(paciente!).collection("Logros").document(detalle).getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                print("Document data: \(String(describing: dataDescription))")
                let fecha = dataDescription!["FechaObt"] as! Timestamp
                self.detailLabel.text = dataDescription!["Descripcion"] as? String
                self.IDLabel.text = dataDescription!["LogroID"] as? String
                self.fechaLabel.text = self.formatter.string(from: fecha.dateValue())
                self.loadImage()
            } else {
                print("Document does not exist")
            }
        }
    }
    
    //TODO: CARGAR IMAGEN DE STORAGE
    func loadImage()  {
        let storage = Storage.storage()
        let profileImageRef = storage.reference(forURL: "gs://healthme-f4b1c.appspot.com/\(imagePath!)")
        // Fetch the download URL
        profileImageRef.downloadURL { url, error in
            if let error = error {
                // Handle any errors
                print("Error took place \(error.localizedDescription)")
            } else {
                // Get the download URL for 'images/stars.jpg'
                print("Profile image download URL \(String(describing: url!))")
                do {
                    let imageData : NSData = try NSData(contentsOf: url!)
                    self.mainImage.image = UIImage(data: imageData as Data)
                    print("Se bajo la foto")
                } catch {
                    print(error)
                }
            }
        }
    }

}
