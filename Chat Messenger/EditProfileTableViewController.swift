//
//  EditProfileTableViewController.swift
//  Chat Messenger
//
//  Created by manukant tyagi on 12/06/22.
//

import UIKit
import Gallery
import ProgressHUD

class EditProfileTableViewController: UITableViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    
    //MARK:  Vars
    
    var gallery: GalleryController!
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextField()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showUserInfo()
    }
    
    // MARK: - IB actions
    
    @IBAction func editButtonPressed(_ sender: Any) {
        showImageGallery()
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
        // todo show status
    }
    
    //MARK: - UpdateUI
    private func showUserInfo(){
        if let user = User.currentUser{
            userNameTextField.text = user.userName
            statusLabel.text = user.status
            if user.avatarLink != "" {
                FileStorage.downloadImage(imageUrl: user.avatarLink) { image in
                    self.avatarImageView.image = image?.circleMasked
                }
            }
        }
    }
    
    //MARK: - Configure
    private func configureTextField(){
        userNameTextField.delegate = self
        userNameTextField.clearButtonMode = .whileEditing
    }
    
    //MARK:  -  gallery
    private func showImageGallery(){
        self.gallery = GalleryController()
        self.gallery.delegate = self
        Config.tabsToShow = [.imageTab, .cameraTab]
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab
        self.present(gallery, animated: true)
    }
    
    //MARK: - Upload Images
    private func uploadAvatarImage(_ image: UIImage){
        let fileDirectory = "Avatars/" + "_\(User.currentId)" + ".jpg"
        FileStorage.uploadImage(image, directory: fileDirectory) { documentLink in
            if var user = User.currentUser{
                user.avatarLink = documentLink ?? ""
                saveUserLocally(user)
                FirebaseUserListener.shared.saveUserToFireStore(user)
            }
            
            // save image locally
            FileStorage.saveFileLocally(fileData: image.jpegData(compressionQuality: 1.0)! as NSData, fileName: User.currentId)
            
        }
    }
}

extension EditProfileTableViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userNameTextField{
            if textField.hasText{
                if var user = User.currentUser{
                    user.userName = textField.text!
                    saveUserLocally(user)
                    FirebaseUserListener.shared.saveUserToFireStore(user)
                }
            }
            textField.resignFirstResponder()
            return false
        }
        return true
    }
}

extension EditProfileTableViewController: GalleryControllerDelegate{
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        if images.count > 0{
            images.first!.resolve { image in
                if image != nil{
                    self.uploadAvatarImage(image!)
                    self.avatarImageView.image = image?.circleMasked 
                }else{
                    ProgressHUD.showError("Couldn't select image")
                }
                
            }
        }
        controller.dismiss(animated: true)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        controller.dismiss(animated: true)
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true)
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true)
    }
    
    
}
