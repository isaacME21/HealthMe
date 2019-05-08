//
//  SideMenuVC.swift
//  HealthMe
//
//  Created by Luis Isaac Maya on 4/22/19.
//  Copyright © 2019 Luis Isaac Maya. All rights reserved.
//

import UIKit
import Firebase


class SideMenuVC: UITableViewController {
    
    let cells = ["","Plan Alimentacion","Citas","Social","Health","Achievements","Chat"]
    let azul = UIColor(red: 54/255, green: 162/255, blue: 235/255, alpha: 1.0)
    
    override func viewWillAppear(_ animated: Bool) {
        configureTableView()
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ProfileMenuCell
            let defaults = UserDefaults.standard
            let email = Auth.auth().currentUser!.email!
            let nombre = defaults.object(forKey: "nombre") as! String
            let imageData = defaults.object(forKey: "ImagenNSData") as! NSData

            cell.ProfileImage.image = UIImage(data: imageData as Data)
            cell.upLabel.text = email
            cell.downLabel.text = nombre
            cell.upLabel.adjustsFontSizeToFitWidth = true
            cell.downLabel.adjustsFontSizeToFitWidth = true
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath)
            cell.textLabel?.text = cells[indexPath.row]
            cell.textLabel?.adjustsFontSizeToFitWidth = true
            cell.textLabel?.textColor = azul
            
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"), object: nil)
        
                switch indexPath.row {
                case 1: NotificationCenter.default.post(name: NSNotification.Name("gotoPlan"), object: nil)
                case 2: NotificationCenter.default.post(name: NSNotification.Name("gotoCitas"), object: nil)
                case 3: NotificationCenter.default.post(name: NSNotification.Name("gotoSocial"), object: nil)
                case 4: NotificationCenter.default.post(name: NSNotification.Name("gotoHealth"), object: nil)
                case 5: NotificationCenter.default.post(name: NSNotification.Name("gotoAchievements"), object: nil)
                case 6: NotificationCenter.default.post(name: NSNotification.Name("gotoChat"), object: nil)
                case 7: NotificationCenter.default.post(name: NSNotification.Name("gotoAvatar"), object: nil)
                case 8: NotificationCenter.default.post(name: NSNotification.Name("gotoConfiguracion"), object: nil)
                default: break
                }
    }
    
    func configureTableView(){
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150.0
    }

}
