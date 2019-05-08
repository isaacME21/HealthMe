//
//  DashBoardVC.swift
//  HealthMe
//
//  Created by Luis Isaac Maya on 11/7/18.
//  Copyright © 2018 Luis Isaac Maya. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import CoreCharts

class DashBoardVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CoreChartViewDataSource,UIPickerViewDelegate,UIPickerViewDataSource {
    
    let db = Firestore.firestore()
    let imagePicker = UIImagePickerController()
    @IBOutlet weak var profileImage: RoundedImage!
    @IBOutlet weak var Avatar: UIImageView!
    @IBOutlet weak var barChart: VCoreBarChart!
    @IBOutlet weak var chartPicker: UIPickerView!
    @IBOutlet weak var nombreLabel: UILabel!
    @IBOutlet weak var edadLabel: UILabel!
    @IBOutlet weak var nutriologoLabel: UILabel!
    @IBOutlet weak var IMCLabel: UILabel!
    @IBOutlet weak var pesoLabel: UILabel!
    @IBOutlet weak var pGrasaLabel: UILabel!
    
    
    var healthObjects = [HealthValues]()
    var lastHealtObject = HealthValues()
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale(identifier: "es_MX")
        formatter.dateFormat = "MMM d"
        return formatter
    }()
    
    let azul = UIColor(red: 54/255, green: 162/255, blue: 235/255, alpha: 1.0)
    let rojo = UIColor(red: 255/255, green: 99/255, blue: 132/255, alpha: 1.0)
    let verde = UIColor(red: 75/255, green: 192/255, blue: 192/255, alpha: 1.0)
    let amarillo = UIColor(red: 255/255, green: 205/255, blue: 86/255, alpha: 1.0)
    
    let opciones = ["Peso","IMC","% Grasa"]
    var opcionGrafica = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showPlan),
                                               name: NSNotification.Name("gotoPlan"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showCitas),
                                               name: NSNotification.Name("gotoCitas"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showSocial),
                                               name: NSNotification.Name("gotoSocial"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showHealth),
                                               name: NSNotification.Name("gotoHealth"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showAchievements),
                                               name: NSNotification.Name("gotoAchievements"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showChat),
                                               name: NSNotification.Name("gotoChat"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showAvatar),
                                               name: NSNotification.Name("gotoAvatar"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showConfiguracion),
                                               name: NSNotification.Name("gotoConfiguracion"),
                                               object: nil)

        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        chartPicker.delegate = self
        barChart.dataSource = self
        
    }
    
    //TODO: BUSCAR EL DOCTOR DEL PACIENTE Y GUARDARLO EN USERDEFAULT
    override func viewWillAppear(_ animated: Bool) {
        var sexo = ""
        SVProgressHUD.show()
        DispatchQueue.global().async {
            self.db.collection("Pacientes").document(Auth.auth().currentUser!.email!).getDocument { (document, error) in
                if let document = document, document.exists {
                    let dataDescription = document.data()
                    print("Document data: \(String(describing: dataDescription))")
                    let defaults = UserDefaults.standard
                    let nutriologo = dataDescription!["nutriologo"] as? String
                    let edad = dataDescription!["edad"] as? Double
                    let nombre = dataDescription!["nombre"] as? String
                    sexo = dataDescription!["sexo"] as? String ?? ""
                    defaults.set(nutriologo!, forKey: "Nutriologo")
                    defaults.set(edad, forKey: "edad")
                    defaults.set(nombre, forKey: "nombre")
                    self.loadData()
                    self.nutriologoLabel.text = nutriologo!
                    self.edadLabel.text = edad!.description
                    self.nombreLabel.text = nombre!
                    self.nutriologoLabel.adjustsFontSizeToFitWidth = true
                    self.loadImage(name: Auth.auth().currentUser!.email!)
                } else {
                    print("Document does not exist")
                    SVProgressHUD.dismiss()
                }
                if sexo == "Hombre"{
                    self.Avatar.loadGif(name: "Hombre")
                }else{
                    self.Avatar.loadGif(name: "Mujer")
                }
            }
        }
        
    }
    
    //TODO: METODOS PARA OBTENER LAS GRAFICAS
    func didTouch(entryData: CoreChartEntry) {
        print(entryData.barTitle)
    }
    func loadCoreChartData() -> [CoreChartEntry] {
        print("se cargo la grafica")
        switch opcionGrafica {
        case 0:
            return obtenerPeso()
        case 1:
            return obtenerIMC()
        case 2:
            return obtenerPgrasa()
        default:
            print("Default")
        }
        return obtenerPeso()
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
    
    //TODO: METODO QUE COLOCA LA IMAGEN ESCOGIDA EN EL UIIMAGEVIEW
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            //profileImage.image = userPickedImage
            guard let imagen = userPickedImage.pngData() else {fatalError("Error al convertir la imagen")}
            uploadProfileImage(imageData: imagen, name: Auth.auth().currentUser!.email!)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    //TODO: LOG OUT
    @IBAction func LogOut(_ sender: UIBarButtonItem) {
        do{
            try Auth.auth().signOut()
            dismiss(animated: true, completion: nil)
        }
        catch{
            print("Error al cerrar sesion")
        }
        
    }
    
    //TODO: MOSTRAR EL MENU
    @IBAction func showMenu(_ sender: UIBarButtonItem) {
        NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"), object: nil)
    }
    //TODO: QUITAR EL MENU AL TOCAR EN LA PANTALLA
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        NotificationCenter.default.post(name: NSNotification.Name("HideSideMenu"), object: nil)
    }
    
    //TODO:ALERTA QUE MOSTRARA LAS OPCIONES PARA CAMBIAR LA FOTO DE PERFIL
    @IBAction func ChangeProfileImage(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Escoge una Imagen", message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = UIColor.green
        
        
        alert.addAction(UIAlertAction(title: "Camara", style: .default, handler: { _ in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Galeria", style: .default, handler: { _ in
            self.openGallary()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancelar", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    //TODO: FUNCION QUE SE ACCIONA AL ABRIR LA FUNCION DE LA CAMARA
    func openCamera(){
        
        if (UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }else{
            let alert  = UIAlertController(title: "Advertencia", message: "No tienes Camara", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    //TODO: FUNCION QUE SE ACCION AL ABRIR LA FUNCION DE GALERIA
    func openGallary(){
        
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    
    //TODO: SEGUES DEL MENU
    @objc func showPlan(){
         performSegue(withIdentifier: "gotoPlan", sender: nil)
    }
    @objc func showCitas(){
         performSegue(withIdentifier: "gotoCitas", sender: nil)
    }
    @objc func showSocial(){
         performSegue(withIdentifier: "gotoSocial", sender: nil)
    }
    @objc func showHealth(){
         performSegue(withIdentifier: "gotoHealth", sender: nil)
    }
    @objc func showAchievements(){
         performSegue(withIdentifier: "gotoAchievements", sender: nil)
    }
    @objc func showChat(){
         performSegue(withIdentifier: "gotoChat", sender: nil)
    }
    @objc func showAvatar(){
         performSegue(withIdentifier: "gotoAvatar", sender: nil)
    }
    @objc func showConfiguracion(){
         performSegue(withIdentifier: "gotoConfiguracion", sender: nil)
    }
    
    
    //TODO: GRAFICAS
    
    //MARK: OBTENER IMC
    func obtenerIMC() -> [CoreChartEntry]{
        var allData = [CoreChartEntry]()
        var dias = [String]()
        var IMC = [Double]()
        
        for object in healthObjects{
            IMC.append(object.IMC)
            dias.append(object.id)
        }
        
        for index in 0..<dias.count{
            let newEntry = CoreChartEntry(id: "\(IMC[index])", barTitle: dias[index], barHeight: Double(IMC[index]), barColor: rojo)
            allData.append(newEntry)
        }
        
        return allData
    }
    //MARK: OBTENER PESO
    func obtenerPeso() -> [CoreChartEntry]{
        var allData = [CoreChartEntry]()
        var dias = [String]()
        var Peso = [Double]()
        
        for object in healthObjects{
            Peso.append(object.peso)
            dias.append(object.id)
        }
        
        for index in 0..<dias.count{
            let newEntry = CoreChartEntry(id: "\(Peso[index])", barTitle: dias[index], barHeight: Double(Peso[index]), barColor: verde)
            allData.append(newEntry)
        }
        
        return allData
    }
    //MARK: OBTENER PORCENTAJE DE GRASA
    func obtenerPgrasa() -> [CoreChartEntry]{
        var allData = [CoreChartEntry]()
        var dias = [String]()
        var Pgrasa = [Double]()
        
        for object in healthObjects{
            Pgrasa.append(object.pGrasa)
            dias.append(object.id)
        }
        
        for index in 0..<dias.count{
            let newEntry = CoreChartEntry(id: "\(Pgrasa[index])", barTitle: dias[index], barHeight: Double(Pgrasa[index]), barColor: amarillo)
            allData.append(newEntry)
        }
        
        return allData
    }
    
    //TODO: GUARDAR LA IMAGEN EN STORAGE
    func uploadProfileImage(imageData: Data , name : String){
        let storageReference = Storage.storage().reference()
        let profileImageRef = storageReference.child("profile").child(name)
        
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "image/png"
        
        profileImageRef.putData(imageData, metadata: uploadMetaData) { (uploadedImageMeta, error) in
            if error != nil
            {
                print("Error took place \(String(describing: error?.localizedDescription))")
                return
            } else {
                print("Meta data of uploaded image \(String(describing: uploadedImageMeta))")
                self.db.collection("Pacientes").document(Auth.auth().currentUser!.email!).updateData(["imagenPerfil" : profileImageRef.fullPath])
                { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                    }
                }
            }
        }
    }
    
    //TODO: CARGAR IMAGEN DE STORAGE
    func loadImage(name : String)  {
        let storageReference = Storage.storage().reference()
        let profileImageRef = storageReference.child("profile").child(name)
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
                    let defaults = UserDefaults.standard
                    defaults.set(imageData, forKey: "ImagenNSData")
                    print("Se bajo la foto")
                    SVProgressHUD.dismiss()
                } catch {
                    print(error)
                    SVProgressHUD.dismiss()
                }
            }
        }
    }
    
    
    func loadData(){
        self.healthObjects.removeAll()
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
                    healthValue.IMC = (data["IMC"] as! Double)
                    healthValue.pGrasa = (data["Pgrasa"] as! Double)
                    healthValue.peso = (data["Peso"] as! Double)
                    healthValue.id = self.formatter.string(from: fechaTemp.dateValue())
                    
                    
                    self.healthObjects.append(healthValue)
                }
                let healthObjectsSorted = self.healthObjects.sorted(by: { $0.fecha < $1.fecha })
                self.healthObjects = healthObjectsSorted
                let last5Objects = self.healthObjects.suffix(5)
                self.healthObjects = Array(last5Objects)
                self.lastHealtObject = self.healthObjects.last!
                self.IMCLabel.text = self.lastHealtObject.IMC.description
                self.pesoLabel.text = self.lastHealtObject.peso.description
                self.pGrasaLabel.text = self.lastHealtObject.pGrasa.description
                self.barChart.reload()
                
            }
        }
    }
    
    
}
