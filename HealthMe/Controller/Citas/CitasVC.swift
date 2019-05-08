//
//  CitasVC.swift
//  HealthMe
//
//  Created by Luis Isaac Maya on 11/26/18.
//  Copyright © 2018 Luis Isaac Maya. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class CitasVC: UIViewController,UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tabla: UITableView!
    @IBOutlet weak var segmentControl: CustomSegmentedControl!
    
    let db = Firestore.firestore()
    
    
    class Cita {
        var cita : Date!
        var paciente : String?
        var descripcion : String?
        var id : String?
        var status : Bool = false
    }
    
    var citas = [Cita]()
    var citasBackUp = [Cita]()
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale(identifier: "es_MX")
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter
    }()
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabla.register(UINib(nibName: "CustomTableViewCell", bundle: nil) , forCellReuseIdentifier: "cell")
        configureTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        SVProgressHUD.show()
        DispatchQueue.global().async {
            self.loadCitas()
        }
        
    }
    
    //Mark: SwipeAction en la derecha
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction{
        let action = UIContextualAction(style: .destructive, title: "delete") { (action, view, completion) in
            self.borrarCita(id: self.citas[indexPath.row].id!)
            completion(true)
        }
        action.image = UIImage(named: "garbage")
        action.backgroundColor = .red
        
        return action
    }
    
    //MARK: SwipeAction a la izquierda
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let complete = completeAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [complete])
    }
    
    
    func completeAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "ReAgendar") { (action, view, completion) in
            
            let defaults = UserDefaults.standard
            defaults.set(self.citas[indexPath.row].id!, forKey: "idAgenda")
            self.reAgendar(date: self.citas[indexPath.row].cita)
            completion(true)
        }
        action.image = UIImage(named: "notebook")
        action.backgroundColor = .green
        
        return action
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return citas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        cell.upLabel.text = citas[indexPath.row].paciente
        cell.downLabel.text = formatter.string(from: citas[indexPath.row].cita!)
        cell.downLabel.minimumScaleFactor = 0.7
        cell.downLabel.adjustsFontSizeToFitWidth = true
        cell.diaLabel.text = "Status"
        cell.mesLabel.text = citas[indexPath.row].status ? "Confirmada" : "En espera"
        
        if cell.mesLabel.text == "Confirmada"{
            cell.mesLabel.textColor = UIColor.green
        }else{
            cell.mesLabel.textColor = UIColor.orange
        }
        
        return cell
    }
    
    func configureTableView(){
        tabla.rowHeight = UITableView.automaticDimension
        tabla.estimatedRowHeight = 120.0
    }
    
    
    func reAgendar(date: Date){
        if let navController = self.navigationController {
            for controller in navController.viewControllers {
                if controller is NutriologoVC {
                    let defaults = UserDefaults.standard
                    defaults.set(date, forKey: "ReAgendar")
                    navController.popToViewController(controller, animated:true)
                    break
                }
            }
        }
    }
    
    
    //TODO: SEGMENT CONTROLLER
    @IBAction func segmentChange(_ sender: CustomSegmentedControl) {
        let hoy = Date()
        citas.removeAll()
        
        switch segmentControl.selectedSegmentIndex {
        case 0:
            print("Año")
            for año in citasBackUp{
                if Calendar.current.isDate(hoy, equalTo: año.cita, toGranularity: .year){
                    citas.append(año)
                }
            }
        case 1:
            print("Dia")
            for dia in citasBackUp{
                if Calendar.current.isDateInToday(dia.cita){
                    citas.append(dia)
                }
            }
        case 2:
            print("Semana")
            for semana in citasBackUp{
                if Calendar.current.isDate(hoy, equalTo: semana.cita, toGranularity: .weekOfYear){
                    citas.append(semana)
                }
            }
        case 3:
            print("Mes")
            for mes in citasBackUp{
                if Calendar.current.isDate(hoy, equalTo: mes.cita, toGranularity: .month){
                    citas.append(mes)
                }
            }
        default:
            print("La opcion no existe")
        }
        print(citas)
        tabla.reloadData()
    }
    
    
    //TODO: FIREBASE METHODS
    func loadCitas(){
        citas.removeAll()
        citasBackUp.removeAll()
        let defaults = UserDefaults.standard
        let doctor = defaults.object(forKey: "Nutriologo") as? String
        let paciente = Auth.auth().currentUser!.email
        db.collection("Nutriologos").document(doctor!).collection("Citas").whereField("Paciente", isEqualTo: paciente!)
            .addSnapshotListener { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    SVProgressHUD.dismiss()
                } else {
                    self.citas.removeAll()
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        let data = document.data()
                        let cita = Cita()
                        
                        
                        let date = data["Cita"] as! Timestamp
                        cita.cita = date.dateValue()
                        cita.paciente = data["Paciente"] as? String
                        cita.descripcion = data["Descripcion"] as? String
                        cita.id = document.documentID
                        cita.status = data["Status"] as! Bool
                        self.citas.append(cita)
                        self.citasBackUp.append(cita)
                        
                    }
                    SVProgressHUD.dismiss()
                    let citasSorted = self.citas.sorted(by: { $0.cita < $1.cita })
                    self.citas = citasSorted
                    self.tabla.reloadData()
                }
        }
        
    }
    
    
    func borrarCita(id : String){
        let defaults = UserDefaults.standard
        let doctor = defaults.object(forKey: "Nutriologo") as? String
        db.collection("Nutriologos").document(doctor!).collection("Citas").document(id).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
                self.loadCitas()
            }
        }
    }
    


}
