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
        var descripcion : String = ""
        var nombre : String = ""
        var id : String?
        var completado : Bool?
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
            destinationVC.imagen = logros[selectedItem].image
    }
    
    
    
    //TODO: FIREBASE METHOD
    func load()  {
        logros.removeAll()
        db.collection("Logros").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    let data = document.data()
                    let logroTemp = logro()
                    let imageData = data["Imagen"] as? Data
                    
                    logroTemp.descripcion = data["Descripcion"] as? String ?? ""
                    logroTemp.nombre = data["Nombre"] as? String ?? ""
                    logroTemp.image = UIImage(data: imageData!)
                    logroTemp.completado = data["Tipo"] as? Bool
                    logroTemp.id = document.documentID
                    
                    self.logros.append(logroTemp)
                }
                SVProgressHUD.dismiss()
                self.mainImage.image = self.logros.last!.image
                self.Achievements.reloadData()
            }
        }
    }
    

}
