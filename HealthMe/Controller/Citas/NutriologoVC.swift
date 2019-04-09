//
//  ViewController2.swift
//  HealthMe
//
//  Created by Luis Isaac Maya on 11/7/18.
//  Copyright © 2018 Luis Isaac Maya. All rights reserved.
//

import UIKit
import SideMenu
import FSCalendar
import Firebase

class NutriologoVC: UIViewController,FSCalendarDataSource, FSCalendarDelegate,UIPickerViewDelegate,UIPickerViewDataSource{
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var HMSPicker: UIPickerView!
    var descripcion : UITextField?
    
    var hour : Int = 0
    var minutes : Int = 0
    var eventObj = AddEvent()
    let time = ["AM","PM"]
    var amPm = 0
    
    var reAgendarCita : Bool = false
    
    let db = Firestore.firestore()
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")!
        formatter.locale = Locale(identifier: "es_MX")
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        HMSPicker.delegate = self
        
        let left = UISwipeGestureRecognizer(target : self, action : #selector(leftSwipe))
        left.direction = .left
        self.view.addGestureRecognizer(left)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        guard let reAgendar = defaults.object(forKey: "ReAgendar") as? Date else{return}
        
        calendar.select(reAgendar)
        reAgendarCita = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        calendar.select(Date())
    }
    
    
    
    
    
    
    
    
    @objc func leftSwipe(){
        performSegue(withIdentifier: "gotoCitas", sender: self)
    }
    
    //TODO: CALENDAR METHODS
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        print("calendar did select date \(self.formatter.string(from: date))")
        if monthPosition == .previous || monthPosition == .next {
            calendar.setCurrentPage(date, animated: true)
        }
    }
    
    //TODO: - PICKERVIEW METHODS
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return 25
        case 1:
            return 60
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return pickerView.frame.size.width/3
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return "\(row)"
        case 1:
            return "\(row)"
        default:
            return ""
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            hour = row 
        case 1:
            minutes = row
        default:
            break;
        }
    }
    
    
    @IBAction func Salir(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func agendarCita(_ sender: UIButton) {
        
        if reAgendarCita == true{
            let alert = UIAlertController(title: "ReAgendar", message: nil, preferredStyle: .alert)
            
            let OKAction = UIAlertAction(title: "Agendar", style: .default, handler: self.reDateFB)
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
            alert.addAction(OKAction)
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true)
            
        }else{
            let alert = UIAlertController(title: "Ingresa una Descripcion", message: nil, preferredStyle: .alert)
            alert.addTextField(configurationHandler: descripcion)
            
            let OKAction = UIAlertAction(title: "Agendar", style: .default, handler: self.sendDateFB)
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
            alert.addAction(OKAction)
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true)
        }
    }
    
    //MARK: INICIALIZACION DE TEXTFIELDS EN ALERTS
    func descripcion(textField: UITextField) {
        descripcion = textField
        descripcion?.placeholder = "Descripcion"
    }
    
    
    
    //TODO: CREAR FECHA
    func crearFecha() -> Date?{
        
        let fecha = calendar.selectedDate
        let calendario = Calendar(identifier: .gregorian)
        
        var dateComponents = DateComponents()
        dateComponents.setValue(hour, for: .hour)
        dateComponents.setValue(minutes, for: .minute)
        dateComponents.timeZone = TimeZone.current
        
        let newDate = calendario.date(byAdding: dateComponents, to: fecha!)
        return newDate
    }
    
    func reAgendarFecha() -> Date? {
        let fecha = calendar.selectedDate
        let calendario = Calendar(identifier: .gregorian)
        let year = calendario.component(.year, from: fecha!)
        let month = calendario.component(.month, from: fecha!)
        let day = calendario.component(.day, from: fecha!)
        
        
        
        // Specify date components
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = hour
        dateComponents.minute = minutes
        
        // Create date from components
        return calendario.date(from: dateComponents)!
    }
    
    
    //TODO: GUARDAR CITA EN FIREBASE
    func sendDateFB(alert: UIAlertAction)  {
        let someDateTime = crearFecha()
        //eventObj.addEventToCalendar(title: "Evento Nutriologo", description: "", startDate: someDateTime!, endDate: someDateTime!)
        
        let defaults = UserDefaults.standard
        let doctor = defaults.object(forKey: "Nutriologo") as? String
        let paciente = Auth.auth().currentUser?.email
        
        
        
        db.collection("Nutriologos").document(doctor!).collection("Citas").addDocument(data:
            ["Cita": someDateTime!,
             "Paciente" : paciente!,
             "Descripcion": descripcion!.text!,
             "Status": false
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added")
            }
        }
    }
    
    
    //TODO: REAGENDAR CITA
    func reDateFB(alert: UIAlertAction)  {
        let defaults = UserDefaults.standard
        let id = defaults.object(forKey: "idAgenda") as? String

        let doctor = defaults.object(forKey: "Nutriologo") as? String
        let newDate = reAgendarFecha()
        
        
        db.collection("Nutriologos").document(doctor!).collection("Citas").document(id!).updateData(["Cita": newDate!]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
                defaults.removeObject(forKey: "ReAgendar")
                defaults.removeObject(forKey: "idAgendar")
                self.reAgendarCita = false
            }
        }
        
    }
    


}
