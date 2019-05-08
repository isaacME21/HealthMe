//
//  HealthViewController.swift
//  HealthMe
//
//  Created by Luis Isaac Maya on 11/26/18.
//  Copyright © 2018 Luis Isaac Maya. All rights reserved.
//

import UIKit
import Firebase
import HealthKit

let healthKitStore = HKHealthStore()

class HealthVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tabla: UITableView!
    
    let db = Firestore.firestore()
    var circunferenciaCompleto = [Double]()
    var circunferenciaOrdenCompleto = [String]()
    var plieguesCompleto = [Double]()
    var plieguesOrdenCompleto = [String]()
    var yourselfValues = [String]()
    var IMCCOmpleto = 0.0
    var pGrasaCompleto = 0.0
    var fechaCompleto = Date()
    let yourself = ["Nombre","IMC","% Grasa","Peso","Talla","Edad"]
    let sections = ["Acerca de ti", "Pliegues", "Circunferencias"]
    
    var healthObjects = [HealthValues]()
    var lastHealtObject = HealthValues()
    let healthManager = HealthKitManager()
    
    var stepValues = [Double]()
    var walkingRunning = [Double]()
    var dates = [Date]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        let left = UISwipeGestureRecognizer(target : self, action : #selector(leftSwipe))
        left.direction = .left
        self.view.addGestureRecognizer(left)
    }
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale(identifier: "es_MX")
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()
    
    
    //TODO: LEFT SWIPE
    @objc func leftSwipe(){
        performSegue(withIdentifier: "gotoGraficas", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! GraficasVC
        
        let last5Objects = healthObjects.suffix(5)
        destinationVC.last5Objects = Array(last5Objects)
        destinationVC.fechas = dates
    }
    
    //TODO: GET ITEMS
    func getItems() -> [[String]]{
        let items = [yourself,circunferenciaOrdenCompleto,plieguesOrdenCompleto]
        return items
    }
    //TODO: GET ITEMS VALUES
    func getValueItems() -> [[String]]{
        var circunferenciaValues = [String]()
        var plieguesValues = [String]()
        
        for x in circunferenciaCompleto{ circunferenciaValues.append(x.description) }
        for y in plieguesCompleto{ plieguesValues.append(y.description) }
        
        let values = [yourselfValues,circunferenciaValues,plieguesValues]
        return values
    }
    
    @IBAction func Salir(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func HealthKit(_ sender: UIBarButtonItem) {
        healthManager.autorizarHealthKit()
    }
    @IBAction func uploadHealthData(_ sender: UIBarButtonItem) {

        
        let dateInWeek = Date()//El dia de hoy
        var calendar = Calendar.current
        calendar.firstWeekday = 1
        let dayOfWeek = calendar.component(.weekday, from: dateInWeek)
        let weekdays = calendar.range(of: .weekday, in: .weekOfYear, for: dateInWeek)!
        var days = (weekdays.lowerBound ..< weekdays.upperBound)
            .compactMap { calendar.date(byAdding: .day, value: $0 - dayOfWeek, to: dateInWeek) }
        
        //MARK: CONFIGURAR ARREGLO PARA BORRAR EL DOMINGO Y PONER TODAS LAS FECHAS AL FINAL DEL DIA MENOS EL ULTIMO
        days.remove(at: 0)
        let today = days.removeLast()
        var NewDays = [Date]()
        for x in days{
            NewDays.append(x.endOfDay)
        }
        
        NewDays.append(today)
        //print(NewDays)
        dates = NewDays
        for y in NewDays{
            readSteps(Fecha: y)
        }

    }
    
    
    
    //TABLEVIEW METHODS
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let items = getItems()
        return items[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let items = getItems()
        let values = getValueItems()
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HealthCell
        let defaults = UserDefaults.standard
        let edad = defaults.object(forKey: "edad") as? Double
        
        if indexPath.section == 0{
            cell.leftLabel.text = items[indexPath.section][indexPath.row]
            switch indexPath.row{
            case 0:
                cell.rightLabel.text = Auth.auth().currentUser!.displayName!
            case 1:
                cell.rightLabel.text = lastHealtObject.IMC.description
            case 2:
                cell.rightLabel.text = lastHealtObject.pGrasa.description
            case 3:
                cell.rightLabel.text = lastHealtObject.peso.description
            case 4:
                cell.rightLabel.text = lastHealtObject.talla.description
            case 5:
                cell.rightLabel.text = edad!.description
            default:
                print("No existe la celda")
            }
            return cell
        }else if indexPath.section == 1{
            cell.leftLabel?.text = items[indexPath.section][indexPath.row]
            cell.rightLabel?.text = values[indexPath.section][indexPath.row]
            return cell
        }else{
            cell.leftLabel?.text = items[indexPath.section][indexPath.row]
            cell.rightLabel?.text = values[indexPath.section][indexPath.row]
            return cell
        }
    }
    
    func loadData(){
        self.plieguesOrdenCompleto.removeAll()
        self.plieguesCompleto.removeAll()
        self.circunferenciaOrdenCompleto.removeAll()
        self.circunferenciaCompleto.removeAll()
        
        let paciente = Auth.auth().currentUser!.email
        db.collection("Pacientes").document(paciente!).collection("Antropometria").getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    let data = document.data()
                    let fechaTemp = data["Fecha"] as! Timestamp
                    let healthValue = HealthValues()
                    healthValue.fecha = fechaTemp.dateValue()
                    healthValue.circunferencia = (data["Circunferencias"] as! NSMutableArray)
                    healthValue.circunferenciaOrden = (data["CircunferenciasOrden"] as! NSMutableArray)
                    healthValue.pliegues = (data["Pliegues"] as! NSMutableArray)
                    healthValue.plieguesOrden = (data["PlieguesOrden"] as! NSMutableArray)
                    healthValue.fecha = fechaTemp.dateValue()
                    healthValue.IMC = (data["IMC"] as! Double)
                    healthValue.pGrasa = (data["Pgrasa"] as! Double)
                    healthValue.peso = (data["Peso"] as! Double)
                    healthValue.talla = (data["Talla"] as! Double)
                    
                    self.healthObjects.append(healthValue)
                }
                let healthObjectsSorted = self.healthObjects.sorted(by: { $0.fecha < $1.fecha })
                self.healthObjects = healthObjectsSorted
                
                self.lastHealtObject = self.healthObjects.last!
                
                self.yourselfValues.append(Auth.auth().currentUser!.displayName!)
                self.yourselfValues.append(self.IMCCOmpleto.description)
                self.yourselfValues.append(self.pGrasaCompleto.description)
                
                for x in self.lastHealtObject.circunferencia! { self.circunferenciaCompleto.append(x as! Double)  }
                for y in self.lastHealtObject.circunferenciaOrden! { self.circunferenciaOrdenCompleto.append(y as! String) }
                for z in self.lastHealtObject.pliegues! { self.plieguesCompleto.append(z as! Double) }
                for w in self.lastHealtObject.plieguesOrden! { self.plieguesOrdenCompleto.append(w as! String) }
                
                self.tabla.reloadData()
            }
        }
    }
    
    
    func saveHealthData(steps : Double , walkingDistance : Double , name : String, Calories : Double , Fecha : Date){
        let paciente = Auth.auth().currentUser!.email
        db.collection("Pacientes").document(paciente!).collection("HealthKit").document(name).setData(
            ["Pasos" : steps,
             "Distancia" : walkingDistance,
             "Fecha" : Fecha,
             "Calorias" : Calories]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    

    func readSteps(Fecha : Date){
        var value: Double = 0
        let steps = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
        
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        let newDate = cal.startOfDay(for: Fecha)
        
        let predicate = HKQuery.predicateForSamples(withStart: newDate, end: Fecha, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate, options: [.cumulativeSum]) { (query, statistics, error) in
            if error != nil {
                print("something went wrong")
            } else if let quantity = statistics?.sumQuantity() {
                value = quantity.doubleValue(for: HKUnit.count())
                print("Pasos => \(value)")
                self.readDistanceWalkingRunning(Fecha: Fecha, steps: value)
            }
        }
        healthKitStore.execute(query)
    }
    
    func readDistanceWalkingRunning(Fecha : Date , steps : Double) {
        var value: Double = 0
        let distanceWalkingRunning = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!
        
        
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        let newDate = cal.startOfDay(for: Fecha)
        
        
        let predicate = HKQuery.predicateForSamples(withStart: newDate, end: Fecha, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: distanceWalkingRunning, quantitySamplePredicate: predicate, options: [.cumulativeSum]) { (query, statistics, error) in
            if error != nil {
                print("something went wrong")
            } else if let quantity = statistics?.sumQuantity() {
                value = quantity.doubleValue(for: HKUnit.meter())
                print("Distancia => \(value)")
                self.readActiveCaloriesBurned(Steps: steps, Walking: value, Fecha: Fecha)
            }
        }
        healthKitStore.execute(query)
    }
    
    func readActiveCaloriesBurned(Steps: Double, Walking : Double, Fecha : Date){
        let activeCaloriesBurned = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!
        
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        let newDate = cal.startOfDay(for: Fecha)
        
        let predicate = HKQuery.predicateForSamples(withStart: newDate, end: Fecha, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: activeCaloriesBurned, quantitySamplePredicate: predicate, options: [.cumulativeSum]) { (query, statistics, error) in
            var value: Double = 0
            
            if error != nil {
                print("something went wrong")
            } else if let quantity = statistics?.sumQuantity() {
                value = quantity.doubleValue(for: HKUnit.kilocalorie())
                print("Active Calories => \(value)")
                self.readBasalEnergyBurned(Steps: Steps, Walking: Walking, Calories: value, Fecha: Fecha)
            }
        }
        healthKitStore.execute(query)
    }
    
    func readBasalEnergyBurned(Steps: Double, Walking : Double, Calories : Double , Fecha : Date){
        let basalCaloriesBurned = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.basalEnergyBurned)!
        let date =  Date()
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        let newDate = cal.startOfDay(for: date)
        
        let predicate = HKQuery.predicateForSamples(withStart: newDate, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: basalCaloriesBurned, quantitySamplePredicate: predicate, options: [.cumulativeSum]) { (query, statistics, error) in
            var value: Double = 0
            
            if error != nil {
                print("something went wrong")
            } else if let quantity = statistics?.sumQuantity() {
                value = quantity.doubleValue(for: HKUnit.kilocalorie())
                print("Basal Calories => \(value)")
                value = value + Calories
                self.saveHealthData(steps: Steps,
                                    walkingDistance: Walking,
                                    name: self.formatter.string(from: Fecha),
                                    Calories: value,
                                    Fecha: Fecha)
            }
        }
        healthKitStore.execute(query)
    }
    
    

}
