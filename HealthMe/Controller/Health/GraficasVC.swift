//
//  GraficasVC.swift
//  HealthMe
//
//  Created by Luis Isaac Maya on 4/25/19.
//  Copyright © 2019 Luis Isaac Maya. All rights reserved.
//

import UIKit
import CoreCharts

class GraficasVC: UIViewController,CoreChartViewDataSource,UIPickerViewDelegate,UIPickerViewDataSource {

    @IBOutlet weak var barChart: VCoreBarChart!
    @IBOutlet weak var chartPicker: UIPickerView!
    
    var last5Objects = [HealthValues](){
        didSet{
            print(last5Objects.count)
            print(last5Objects)
            prepareHealthObjects()
        }
    }
    
    var fechas = [Date]()
    
    var circunferenciaCompleto = [Double]()
    var circunferenciaOrdenCompleto = [String]()
    var plieguesCompleto = [Double]()
    var plieguesOrdenCompleto = [String]()

    class fixedObject{
        var circunferencia = [Double]()
        var circunferenciaOrden = [String]()
        var pliegues = [Double]()
        var plieguesOrden = [String]()
        var id : String?
        var IMC = 0.0
        var peso = 0.0
        var pGrasa = 0.0
    }
    
    var fixedObjects = [fixedObject]()
    
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale(identifier: "es_MX")
        formatter.dateFormat = "MMM d"
        return formatter
    }()
    
    let opciones = ["Circunferencia Brazo","Circunferencia Muñeca","Circunferencia Cintura","Circunferencia Cadera","Circunferencia Humeral",
                    "Pliegues Tricipital","Pliegues Subescapular","Pliegues Bicipital","Pliegues Suprailiaco",
                    "IMC","Peso","Porcentaje de Grasa"]
    var opcionGrafica = 0
    
    let azul = UIColor(red: 54/255, green: 162/255, blue: 235/255, alpha: 1.0)
    let rojo = UIColor(red: 255/255, green: 99/255, blue: 132/255, alpha: 1.0)
    let verde = UIColor(red: 75/255, green: 192/255, blue: 192/255, alpha: 1.0)
    let amarillo = UIColor(red: 255/255, green: 205/255, blue: 86/255, alpha: 1.0)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chartPicker.delegate = self
        barChart.dataSource = self
        
        let left = UISwipeGestureRecognizer(target : self, action : #selector(leftSwipe))
        left.direction = .left
        self.view.addGestureRecognizer(left)
    }
    
    //TODO: LEFT SWIPE
    @objc func leftSwipe(){
        performSegue(withIdentifier: "gotoHealthChart", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! HealthChartVC
        destinationVC.fechas = fechas
    }
    
    //TODO: METODOS PARA OBTENER LAS GRAFICAS
    func didTouch(entryData: CoreChartEntry) {
        print(entryData.barTitle)
    }
    func loadCoreChartData() -> [CoreChartEntry] {
        print("se cargo la grafica")
        switch opcionGrafica {
        case 0:
            return obtenerCincunferenciaBrazo()
        case 1:
            return obtenerCincunferenciaMuñeca()
        case 2:
            return obtenerCincunferenciaCintura()
        case 3:
            return obtenerCincunferenciaCadera()
        case 4:
            return obtenerCincunferenciaHumeral()
        case 5:
            return obtenerPlieguesTricipital()
        case 6:
            return obtenerPlieguesSubescapular()
        case 7:
            return obtenerPlieguesBicipital()
        case 8:
            return obtenerPlieguesSuprailiaco()
        case 9:
            return obtenerIMC()
        case 10:
            return obtenerPeso()
        case 11:
            return obtenerPgrasa()
        default:
            print("Default")
        }
        return obtenerCincunferenciaBrazo()
    }
    
    
    //TODO: OPCIONES UIPICKER METHODS
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
    func obtenerCincunferenciaBrazo() -> [CoreChartEntry]{
        var allData = [CoreChartEntry]()
        var dias = [String]()
        var circunferencias = [Double]()
        
        for object in fixedObjects{
            circunferencias.append(object.circunferencia[0])
            dias.append(object.id!)
        }
        
        for index in 0..<dias.count{
            let newEntry = CoreChartEntry(id: "\(circunferencias[index])", barTitle: dias[index], barHeight: Double(circunferencias[index]), barColor: azul)
            allData.append(newEntry)
        }
        
        return allData
    }
    
    func obtenerCincunferenciaMuñeca() -> [CoreChartEntry]{
        var allData = [CoreChartEntry]()
        var dias = [String]()
        var circunferencias = [Double]()
        
        for object in fixedObjects{
            circunferencias.append(object.circunferencia[1])
            dias.append(object.id!)
        }
        
        for index in 0..<dias.count{
            let newEntry = CoreChartEntry(id: "\(circunferencias[index])", barTitle: dias[index], barHeight: Double(circunferencias[index]), barColor: rojo)
            allData.append(newEntry)
        }
        
        return allData
    }
    
    func obtenerCincunferenciaCintura() -> [CoreChartEntry]{
        var allData = [CoreChartEntry]()
        var dias = [String]()
        var circunferencias = [Double]()
        
        for object in fixedObjects{
            circunferencias.append(object.circunferencia[2])
            dias.append(object.id!)
        }
        
        for index in 0..<dias.count{
            let newEntry = CoreChartEntry(id: "\(circunferencias[index])", barTitle: dias[index], barHeight: Double(circunferencias[index]), barColor: verde)
            allData.append(newEntry)
        }
        
        return allData
    }
    
    func obtenerCincunferenciaCadera() -> [CoreChartEntry]{
        var allData = [CoreChartEntry]()
        var dias = [String]()
        var circunferencias = [Double]()
        
        for object in fixedObjects{
            circunferencias.append(object.circunferencia[3])
            dias.append(object.id!)
        }
        
        for index in 0..<dias.count{
            let newEntry = CoreChartEntry(id: "\(circunferencias[index])", barTitle: dias[index], barHeight: Double(circunferencias[index]), barColor: amarillo)
            allData.append(newEntry)
        }
        
        return allData
    }
    
    func obtenerCincunferenciaHumeral() -> [CoreChartEntry]{
        var allData = [CoreChartEntry]()
        var dias = [String]()
        var circunferencias = [Double]()
        
        for object in fixedObjects{
            circunferencias.append(object.circunferencia[4])
            dias.append(object.id!)
        }
        
        for index in 0..<dias.count{
            let newEntry = CoreChartEntry(id: "\(circunferencias[index])", barTitle: dias[index], barHeight: Double(circunferencias[index]), barColor: azul)
            allData.append(newEntry)
        }
        
        return allData
    }
    
    
    func obtenerPlieguesTricipital() -> [CoreChartEntry]{
        var allData = [CoreChartEntry]()
        var dias = [String]()
        var pliegues = [Double]()
        
        for object in fixedObjects{
            pliegues.append(object.circunferencia[0])
            dias.append(object.id!)
        }
        
        for index in 0..<dias.count{
            let newEntry = CoreChartEntry(id: "\(pliegues[index])", barTitle: dias[index], barHeight: Double(pliegues[index]), barColor: rojo)
            allData.append(newEntry)
        }
        
        return allData
    }
    
    func obtenerPlieguesSubescapular() -> [CoreChartEntry]{
        var allData = [CoreChartEntry]()
        var dias = [String]()
        var pliegues = [Double]()
        
        for object in fixedObjects{
            pliegues.append(object.circunferencia[1])
            dias.append(object.id!)
        }
        
        for index in 0..<dias.count{
            let newEntry = CoreChartEntry(id: "\(pliegues[index])", barTitle: dias[index], barHeight: Double(pliegues[index]), barColor: verde)
            allData.append(newEntry)
        }
        
        return allData
    }
    
    func obtenerPlieguesBicipital() -> [CoreChartEntry]{
        var allData = [CoreChartEntry]()
        var dias = [String]()
        var pliegues = [Double]()
        
        for object in fixedObjects{
            pliegues.append(object.circunferencia[2])
            dias.append(object.id!)
        }
        
        for index in 0..<dias.count{
            let newEntry = CoreChartEntry(id: "\(pliegues[index])", barTitle: dias[index], barHeight: Double(pliegues[index]), barColor: amarillo)
            allData.append(newEntry)
        }
        
        return allData
    }
    
    func obtenerPlieguesSuprailiaco() -> [CoreChartEntry]{
        var allData = [CoreChartEntry]()
        var dias = [String]()
        var pliegues = [Double]()
        
        for object in fixedObjects{
            pliegues.append(object.circunferencia[3])
            dias.append(object.id!)
        }
        
        for index in 0..<dias.count{
            let newEntry = CoreChartEntry(id: "\(pliegues[index])", barTitle: dias[index], barHeight: Double(pliegues[index]), barColor: azul)
            allData.append(newEntry)
        }
        
        return allData
    }
    
    func obtenerIMC() -> [CoreChartEntry]{
        var allData = [CoreChartEntry]()
        var dias = [String]()
        var IMC = [Double]()
        
        for object in fixedObjects{
            IMC.append(object.IMC)
            dias.append(object.id!)
        }
        
        for index in 0..<dias.count{
            let newEntry = CoreChartEntry(id: "\(IMC[index])", barTitle: dias[index], barHeight: Double(IMC[index]), barColor: rojo)
            allData.append(newEntry)
        }
        
        return allData
    }
    
    func obtenerPeso() -> [CoreChartEntry]{
        var allData = [CoreChartEntry]()
        var dias = [String]()
        var Peso = [Double]()
        
        for object in fixedObjects{
            Peso.append(object.peso)
            dias.append(object.id!)
        }
        
        for index in 0..<dias.count{
            let newEntry = CoreChartEntry(id: "\(Peso[index])", barTitle: dias[index], barHeight: Double(Peso[index]), barColor: verde)
            allData.append(newEntry)
        }
        
        return allData
    }
    
    func obtenerPgrasa() -> [CoreChartEntry]{
        var allData = [CoreChartEntry]()
        var dias = [String]()
        var Pgrasa = [Double]()
        
        for object in fixedObjects{
            Pgrasa.append(object.pGrasa)
            dias.append(object.id!)
        }
        
        for index in 0..<dias.count{
            let newEntry = CoreChartEntry(id: "\(Pgrasa[index])", barTitle: dias[index], barHeight: Double(Pgrasa[index]), barColor: amarillo)
            allData.append(newEntry)
        }
        
        return allData
    }
    
    func prepareHealthObjects(){
            for object in last5Objects{
                let objectFixed = fixedObject()
                
                for x in object.circunferencia! { circunferenciaCompleto.append(x as! Double)  }
                for y in object.circunferenciaOrden! { circunferenciaOrdenCompleto.append(y as! String) }
                for z in object.pliegues! { plieguesCompleto.append(z as! Double) }
                for w in object.plieguesOrden! { plieguesOrdenCompleto.append(w as! String) }
                
                objectFixed.circunferencia = circunferenciaCompleto
                objectFixed.circunferenciaOrden = circunferenciaOrdenCompleto
                objectFixed.pliegues = plieguesCompleto
                objectFixed.plieguesOrden = plieguesOrdenCompleto
                objectFixed.id = formatter.string(from: object.fecha)
                objectFixed.IMC = object.IMC
                objectFixed.peso = object.peso
                objectFixed.pGrasa = object.pGrasa
                fixedObjects.append(objectFixed)
                
                circunferenciaCompleto.removeAll()
                circunferenciaOrdenCompleto.removeAll()
                plieguesCompleto.removeAll()
                plieguesOrdenCompleto.removeAll()
        }
        print("Se termino de arreglar los arrays")
    }

}
