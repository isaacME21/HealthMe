//
//  SideMenuVC.swift
//  HealthMe
//
//  Created by Luis Isaac Maya on 4/22/19.
//  Copyright © 2019 Luis Isaac Maya. All rights reserved.
//

import UIKit

class SideMenuVC: UITableViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"), object: nil)
        
                switch indexPath.row {
                case 0: NotificationCenter.default.post(name: NSNotification.Name("gotoPlan"), object: nil)
                case 1: NotificationCenter.default.post(name: NSNotification.Name("gotoCitas"), object: nil)
                case 2: NotificationCenter.default.post(name: NSNotification.Name("gotoSocial"), object: nil)
                case 3: NotificationCenter.default.post(name: NSNotification.Name("gotoHealth"), object: nil)
                case 4: NotificationCenter.default.post(name: NSNotification.Name("gotoAchievements"), object: nil)
                case 5: NotificationCenter.default.post(name: NSNotification.Name("gotoChat"), object: nil)
                case 6: NotificationCenter.default.post(name: NSNotification.Name("gotoAvatar"), object: nil)
                case 7: NotificationCenter.default.post(name: NSNotification.Name("gotoConfiguracion"), object: nil)
                default: break
                }
    }

}
