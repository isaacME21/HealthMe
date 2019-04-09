//
//  ViewController1.swift
//  HealthMe
//
//  Created by Luis Isaac Maya on 11/7/18.
//  Copyright © 2018 Luis Isaac Maya. All rights reserved.
//

import UIKit
import SideMenu
import Firebase

class PlanAlimentacionVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    

    @IBOutlet weak var segmentControl: CustomSegmentedControl!
    @IBOutlet weak var tabla: UITableView!
    
    let db = Firestore.firestore()
    var menus : String = ""
    var menusTableview = [String]()
    var dias = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        loadMenus()
    }
    
    @IBAction func Salir(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    //TODO: TABLEVIEW METHODS
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menusTableview.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {fatalError("Error en la celda")}
        cell.textLabel?.text = menusTableview[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "gotoMenu", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! MenuVC
        
        if let indexPath = tabla.indexPathForSelectedRow{
            destinationVC.menu = menusTableview[indexPath.row]
        }
    }
    
    
    //TODO: FIREBASE METHODS
    
    func loadMenus(){
        menusTableview.removeAll()
        db.collection("Test").getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    self.menusTableview.append(document.documentID)
                }
                self.segmentControl.commaSeparatedButtonTitles = "Hoy,Semana,Mes"
                self.tabla.reloadData()
            }
        }
    }
    
    
    
    

}
