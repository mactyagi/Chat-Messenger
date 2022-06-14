//
//  SettingTableTableViewController.swift
//  Chat Messenger
//
//  Created by manukant tyagi on 11/06/22.
//

import UIKit

class SettingTableViewController: UITableViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var versionLabel: UILabel!
    //MARK: - view Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showUserInfo()
    }
    
    // MARK: - TableView Delegates
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "tableViewBackgroundColor")
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 && indexPath.row == 0{
            performSegue(withIdentifier: "settingToEditProfile", sender: self)
        }
    }
    
    //MARK: - IBActions
    @IBAction func tellFriendButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func termAndConditonButtonPressed(_ sender: UIButton) {
    }
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        FirebaseUserListener.shared.logoutCurrentUser { error in
            if error == nil{
                let loginView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "loginView")
                DispatchQueue.main.async {
                    loginView.modalPresentationStyle = .fullScreen
                    self.present(loginView, animated: true)
                }
            }
        }
    }
    
    //MARK: - UpdateUI
    private func showUserInfo(){
        if let user = User.currentUser{
            userNameLabel.text = user.userName
            statusLabel.text = user.status
            versionLabel.text = "App version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")"
            if user.avatarLink != "" {
                // download and set avatar image
                FileStorage.downloadImage(imageUrl: user.avatarLink) { image in
                    self.avatarImageView.image = image?.circleMasked
                }
            }
        }
    }
}
