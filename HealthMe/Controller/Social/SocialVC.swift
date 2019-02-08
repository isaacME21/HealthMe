//
//  ViewController3.swift
//  HealthMe
//
//  Created by Luis Isaac Maya on 11/7/18.
//  Copyright © 2018 Luis Isaac Maya. All rights reserved.
//

import UIKit
import SideMenu
import FBSDKCoreKit
import FBSDKLoginKit
import SwiftyJSON
import SVProgressHUD

class SocialVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tabla: UITableView!
    @IBOutlet weak var rightBarButton: UIBarButtonItem!
    
    var imageURL : URL!{
        didSet{
            print("Se obtuvo el URL")
            load(url: imageURL!)
        }
    }
    
    
    var postDate = [Int]()
    var posts = [String]()
    var userProfile = [String]()
    var profilePicture : UIImage = UIImage()
    
    //MARK: REFRESH CONTROL
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:#selector(SocialVC.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.green
        
        return refreshControl
    }()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewDidLoad")
        self.tabla.addSubview(self.refreshControl)
        //getFBUserData()
        //getFBUserData2()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if((FBSDKAccessToken.current()) != nil){
            SVProgressHUD.show(withStatus: "Cargando")
            DispatchQueue.global(qos: .background).async {
                self.getFBUserData()
                self.getFBUserData2()
            }
        }
        
    }
    
    //TODO: - HANDLE REFRESH
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.getFBUserData()
        self.getFBUserData()
        refreshControl.endRefreshing()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        cell.caption.text = posts[indexPath.row]
        cell.name.text = userProfile[0]
        cell.timeAgo.text = "\(postDate[indexPath.row])"
        cell.profileImageView.image = profilePicture
        
        return cell
    }
    
    
    
    
    @IBAction func Salir(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    

    
    @IBAction func logInFB(_ sender: UIBarButtonItem) {
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email","public_profile","user_posts"], from: self) { (result, error) -> Void in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                // if user cancel the login
                if (result?.isCancelled)!{
                    return
                }
                if(fbloginresult.grantedPermissions.contains("email"))
                {
                    SVProgressHUD.show(withStatus: "Cargando")
                    DispatchQueue.global(qos: .background).async {
                        self.getFBUserData()
                        self.getFBUserData2()
                    }
                }
            }
        }
    }
    
    func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me/feed", parameters: ["fields": "message,created_time"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    //everything works print the user data
                    let json = JSON(result!)
                    let feedDictionary = json["data"]
                    
                    self.postDate.removeAll()
                    self.posts.removeAll()
                    
                    for (_, object) in feedDictionary {
                        if object["message"].stringValue != ""{
                            self.posts.append(object["message"].stringValue)
                            self.postDate.append(object["created_time"].intValue)
                        }
                    }
                    print(self.posts)
                    print(self.postDate)
                    print(self.posts.count)
                    print(self.postDate.count)
                    self.tabla.reloadData()
                    SVProgressHUD.dismiss()
                }
            })
        }
    }
    
    
    func getFBUserData2(){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    //everything works print the user data
                    let json = JSON(result!)
                    self.userProfile.removeAll()
                    self.userProfile.append(json["name"].stringValue)
                    self.userProfile.append(json["picture"]["data"]["url"].stringValue)
                    self.imageURL = URL(string: json["picture"]["data"]["url"].stringValue)
                    print(self.userProfile)
                }
            })
        }
    }
    
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.profilePicture = image
                    }
                }
            }
        }
    }
    
    
   

}
