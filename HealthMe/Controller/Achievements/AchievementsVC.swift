//
//  AchievementsVC.swift
//  HealthMe
//
//  Created by Luis Isaac Maya on 11/26/18.
//  Copyright © 2018 Luis Isaac Maya. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class AchievementsVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    
    let doctor = Auth.auth().currentUser?.displayName
    let user = Auth.auth().currentUser?.email
    let db = Firestore.firestore()
    
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var Achievements: UICollectionView!
    
    class logro {
        var image : UIImage?
        var imagePath : String?
        var descripcion : String = ""
        var nombre : String = ""
        var id : String?
        var completado : Bool?
        var fecha = Date()
    }
    
    var logros = [logro]()
    var selectedItem : Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Achievements.dragInteractionEnabled = true
        Achievements.allowsSelection = true
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        SVProgressHUD.show(withStatus: "Cargando")
        DispatchQueue.global().async {
            self.load()
        }
    }
    
    @IBAction func Salir(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    //TODO: COLLECTIONVIEW METHODS
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return logros.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let view = Achievements.dequeueReusableCell(withReuseIdentifier: "view", for: indexPath) as! CustomCollectionViewCell
        view.image.image = logros[indexPath.row].image
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Item Selected : \(indexPath.row)")
        selectedItem = indexPath.row
        performSegue(withIdentifier: "gotoDetalle", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! DetalleVC
        
        destinationVC.detalle = logros[selectedItem].id!
        destinationVC.imagePath = logros[selectedItem].imagePath
    }
    
    
    
    //TODO: FIREBASE METHOD
    func load()  {
        logros.removeAll()
        var bandera = 0  //Bandera que indica cuando acabo de bajar todas las fotos
        db.collection("Pacientes").document(Auth.auth().currentUser!.email!).collection("Logros").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("entro a bajar info")
                    //print("\(document.documentID) => \(document.data())")
                    let data = document.data()
                    let logroTemp = logro()
                    let fecha = data["FechaObt"] as! Timestamp
                    let imagePath = data["Imagen"] as? String ?? ""
                    
                    logroTemp.descripcion = data["Descripcion"] as? String ?? ""
                    logroTemp.nombre = data["LogroID"] as? String ?? ""
                    logroTemp.imagePath = imagePath
                    logroTemp.completado = data["Obtenido"] as? Bool
                    logroTemp.id = document.documentID
                    logroTemp.fecha = fecha.dateValue()
                    self.logros.append(logroTemp)
                    
                }
                print(self.logros.count)
                let logrosObjectsSorted = self.logros.sorted(by: { $0.fecha < $1.fecha })
                self.logros = logrosObjectsSorted
                
                for logro in self.logros{
                    let storage = Storage.storage()
                    let imagePath = logro.imagePath
                    print("Entro a bajar fotos")
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
                                logro.image = UIImage(data: imageData as Data)
                                print("Se bajo la foto")
                                
                                //SI NO ESTA COMPLETADO CONVERTIR LA IMAGEN A ESCALA DE GRISES
                                if logro.completado == false{
                                    let imageNoir = logro.image?.noir
                                    logro.image = imageNoir!
                                }
                                
                                bandera = bandera + 1
                                if bandera == self.logros.count{
                                    SVProgressHUD.dismiss()
                                    print("Se bajaron todas la fotos")
                                    self.mainImage.image = self.logros.last!.image
                                    self.Achievements.reloadData()
                                }
                            } catch {
                                print(error)
                                SVProgressHUD.dismiss()
                            }
                        }
                    }
                }
            }
        }
    }
    



}
