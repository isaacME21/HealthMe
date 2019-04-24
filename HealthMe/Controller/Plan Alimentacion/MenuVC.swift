//
//  MenuVC.swift
//  HealthMe
//
//  Created by Luis Isaac Maya on 4/6/19.
//  Copyright © 2019 Luis Isaac Maya. All rights reserved.
//

import UIKit
import Firebase

class MenuVC: UIViewController,UITableViewDataSource,UITableViewDelegate {
   

    @IBOutlet weak var segmentControl: CustomSegmentedControl!
    @IBOutlet weak var tabla: UITableView!
    let db = Firestore.firestore()
    var days = ""
    var tiempos = [String]()
    var dias = [String]()
    var horas = [Date]()
    var menuCompleto = [diasObj]()
    var menuFiltrado = [tiemposObj]()
    
    var menu : String = ""{
        didSet{
            loadPlan(Plan: menu)
        }
    }
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale(identifier: "es_MX")
        formatter.dateFormat = " HH:mm"
        return formatter
    }()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    //TODO: TABLEVIEW METHODS
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuFiltrado.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FoodCell
        cell.NombreLabel.text = menuFiltrado[indexPath.row].name
        cell.tiempoLabel.text = formatter.string(from: horas[indexPath.row])
        cell.descripcionLabel.text = getDescription(array: menuFiltrado[indexPath.row].tiemposArray!)
        cell.descripcionLabel.adjustsFontSizeToFitWidth = true
        cell.NombreLabel.adjustsFontSizeToFitWidth = true
        cell.tiempoLabel.adjustsFontSizeToFitWidth = true
        
        return cell
    }
    
    
    
    //TODO: GET DESCRIPTION
    func getDescription(array : NSMutableArray) -> String {
        var descriptionString = ""
        for x in array{
            let y = x as! String
            descriptionString = "🔘" + y + "\n" + descriptionString
        }
        return descriptionString
    }
    
    
    
    //TODO: SEGMENT CONTROL METHODS
    @IBAction func segmentChange(_ sender: CustomSegmentedControl) {
        
        switch segmentControl.selectedSegmentIndex {
        case 0:
            menuFiltrado = menuCompleto[0].tiempos
        case 1:
            menuFiltrado = menuCompleto[1].tiempos
        case 2:
            menuFiltrado = menuCompleto[2].tiempos
        case 3:
            menuFiltrado = menuCompleto[3].tiempos
        case 4:
            menuFiltrado = menuCompleto[4].tiempos
        case 5:
            menuFiltrado = menuCompleto[5].tiempos
        default:
            print("La opcion no existe")
        }
        
        tabla.reloadData()
    }
    
    

    //TODO: CARGAR PLAN DE ALIMENTACION
    func loadPlan(Plan : String){
        menuCompleto.removeAll()
        db.collection("Pacientes").document(Auth.auth().currentUser!.email!).collection("Planes").document(Plan).getDocument { (document, error) in
            if let document = document, document.exists {
                
                var daysTemp = ""
                let dataDescription = document.data()
                //print("Document data: \(String(describing: dataDescription))")
                
                let ordenDias = dataDescription!["OrdenDias"] as! NSMutableArray
                let ordenTiempos = dataDescription!["OrdenTiempos"] as! NSMutableArray
                let horaTiempos = dataDescription!["HoraTiempos"] as! NSMutableArray
                let alimentos = dataDescription!["Alimentos"] as! NSDictionary
                
                for dia in ordenDias{
                    let diaTemp = dia as! String
                    self.dias.append(diaTemp)
                    daysTemp = daysTemp + "," + diaTemp.prefix(3)
                }
                for tiempo in ordenTiempos{
                    let tiempoTemp = tiempo as! String
                    self.tiempos.append(tiempoTemp)
                }
                for hora in horaTiempos{
                    let horaTemp = hora as! Timestamp
                    self.horas.append(horaTemp.dateValue())
                }
                for (day,alimento) in alimentos{
                    let food = alimento as! NSDictionary
                    let daysObj = diasObj()
                    daysObj.name = day as? String
                    
                    for (key,alimentoTemp) in food{
                        let alimentoArray = alimentoTemp as! NSMutableArray
                        let tiempoObj = tiemposObj()
                        tiempoObj.name = key as? String
                        tiempoObj.tiemposArray = alimentoArray
                        daysObj.tiempos.append(tiempoObj)
                    }
                    self.menuCompleto.append(daysObj)
                }
                
                
                var menuCompletoSorted = [diasObj]()
                for x in self.dias{
                    for y in self.menuCompleto{
                        guard let nombre = y.name else {fatalError("Error al acomodar los dias")}
                        if x == nombre{
                            menuCompletoSorted.append(y)
                        }
                    }
                }
                self.menuCompleto = menuCompletoSorted
                menuCompletoSorted.removeAll()
                

                
                var diasCompletoSorted = [tiemposObj]()
                for a in self.menuCompleto{
                    for b in self.tiempos{
                        for c in a.tiempos{
                            guard let nombre = c.name else {fatalError("Error al acomodar las comidas")}
                            if b == nombre{
                                diasCompletoSorted.append(c)
                            }
                        }
                    }
                    a.tiempos = diasCompletoSorted
                    diasCompletoSorted.removeAll()
                }
                
                self.menuFiltrado = self.menuCompleto[0].tiempos
                
                for x in self.menuFiltrado{
                    print(x.name!)
                    for y in x.tiemposArray!{
                        print(y as! String)
                    }
                }
                
                
                
                
                
                self.days = String(daysTemp.dropFirst())
                self.segmentControl.commaSeparatedButtonTitles = self.days
                
                self.tabla.reloadData()
            } else {
                print("Document does not exist")
            }
        }
    }

}
