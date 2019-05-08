//
//  HealthChartVC.swift
//  HealthMe
//
//  Created by Luis Isaac Maya on 4/27/19.
//  Copyright © 2019 Luis Isaac Maya. All rights reserved.
//

import UIKit
import Firebase
import CoreCharts

class HealthChartVC: UIViewController,CoreChartViewDataSource,UIPickerViewDelegate,UIPickerViewDataSource {
    
    
    @IBOutlet weak var chartPicker: UIPickerView!
    @IBOutlet weak var barChart: VCoreBarChart!
    
    
    
    var fechas = [Date](){
        didSet{
            for x in fechas{nameDocument.append(formatter.string(from: x))}
        }
    }
    var nameDocument = [String]()
    var calorias = [Double]()
    var pasos = [Double]()
    var walking = [Double]()
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale(identifier: "es_MX")
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()
    
    let formatter2: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale(identifier: "es_MX")
        formatter.dateFormat = "E, d"
        return formatter
    }()
    
    let db = Firestore.firestore()
    
    class healthKitObject{
        var calorias : Double?
        var pasos : Double?
        var walking : Double?
        var fecha = Date()
    }
    
    
    let opciones = ["Pasos", "Calorias", "Distancia Recorrida"]
    var opcionGrafica = 0
    
    let azul = UIColor(red: 54/255, green: 162/255, blue: 235/255, alpha: 1.0)
    let rojo = UIColor(red: 255/255, green: 99/255, blue: 132/255, alpha: 1.0)
    let verde = UIColor(red: 75/255, green: 192/255, blue: 192/255, alpha: 1.0)
    let amarillo = UIColor(red: 255/255, green: 205/255, blue: 86/255, alpha: 1.0)
    
    var healthKitObjects = [healthKitObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chartPicker.delegate = self
        barChart.dataSource = self
        print(nameDocument)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        load()
    }
    
    //TODO: METODOS PARA OBTENER LAS GRAFICAS
    func didTouch(entryData: CoreChartEntry) {
        print(entryData.barTitle)
    }
    func loadCoreChartData() -> [CoreChartEntry] {
        print("se cargo la grafica")
        
        switch opcionGrafica {
        case 0:
            return obtenerPasos()
        case 1:
            return obtenerCalorias()
        case 2:
            return obtenerDistancia()

        default:
            print("Default")
        }
        return obtenerPasos()
    }
    
    //TODO: - PICKERVIEW METHODS
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return opciones.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return opciones[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        opcionGrafica = row
        barChart.reload()
    }
    
    //TODO: GRAFICAS
    func obtenerCalorias() -> [CoreChartEntry]{
        var allData = [CoreChartEntry]()
        var Nombres = [String]()
        var Datos = [Double]()
        
        for object in healthKitObjects{
            Datos.append(object.calorias!)
            Nombres.append(formatter2.string(from: object.fecha))
        }
        
        for index in 0..<Nombres.count{
            let newEntry = CoreChartEntry(id: "\(Datos[index])", barTitle: Nombres[index], barHeight: Double(Datos[index]), barColor: rojo)
            allData.append(newEntry)
        }
        
        return allData
    }
    
    func obtenerPasos() -> [CoreChartEntry]{
        var allData = [CoreChartEntry]()
        var Nombres = [String]()
        var Datos = [Double]()
        
        for object in healthKitObjects{
            Datos.append(object.pasos!)
            Nombres.append(formatter2.string(from: object.fecha))
        }
        
        for index in 0..<Nombres.count{
            let newEntry = CoreChartEntry(id: "\(Datos[index])", barTitle: Nombres[index], barHeight: Double(Datos[index]), barColor: azul)
            allData.append(newEntry)
        }
        
        return allData
    }
    
    func obtenerDistancia() -> [CoreChartEntry]{
        var allData = [CoreChartEntry]()
        var Nombres = [String]()
        var Datos = [Double]()
        
        for object in healthKitObjects{
            Datos.append(object.walking!)
            Nombres.append(formatter2.string(from: object.fecha))
        }
        
        for index in 0..<Nombres.count{
            let newEntry = CoreChartEntry(id: "\(Datos[index])", barTitle: Nombres[index], barHeight: Double(Datos[index]), barColor: verde)
            allData.append(newEntry)
        }
        
        return allData
    }
    
    
    //TODO: LOAD DATA
    func load(){
        let paciente = Auth.auth().currentUser!.email!
        healthKitObjects.removeAll()
        db.collection("Pacientes").document(paciente).collection("HealthKit").getDocuments{ (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    if self.nameDocument.contains(document.documentID){
                        let data = document.data()
                        let fecha = data["Fecha"] as! Timestamp
                        
                        let item = healthKitObject()
                        item.fecha = fecha.dateValue()
                        item.calorias = data["Calorias"] as? Double
                        item.pasos = data["Pasos"] as? Double
                        item.walking = data["Distancia"] as? Double
                        
                        self.healthKitObjects.append(item)
                    }
                }
                print(self.healthKitObjects)
                self.barChart.reload()
            }
        }
    }



}
