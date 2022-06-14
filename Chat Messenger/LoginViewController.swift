//
//  ViewController.swift
//  Chat Messenger
//
//  Created by manukant tyagi on 07/06/22.
//

import UIKit
import ProgressHUD

class LoginViewController: UIViewController {
// MARK: - IBOutlet
    //labels
    @IBOutlet weak var emailLabelOutlet: UILabel!
    @IBOutlet weak var passwordLabelOutlet: UILabel!
    @IBOutlet weak var repeatpasswordLabel: UILabel!
    @IBOutlet weak var signupLabel: UILabel!
    
    //textfields
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var repeatTextfield: UITextField!
    
    //Buttons
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var resendEmailButton: UIButton!
    
    
    //views
    @IBOutlet weak var repeatPasswordLineView: UIView!
    
    
    //MARK: - var
    var isLogin = true
    
    
    //MARK: - view Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundTap()
        updateUIFor(login: true)
        setupTextfieldDelegates()
        // Do any additional setup after loading the view.
    }
    
    //MARK: - IBActions
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        if isDataInputedFor(type: isLogin ? "login" : "register"){
            // register / login
            isLogin ? loginUser() : registerUser()
        }else{
            ProgressHUD.showFailed("All Fields are required")
        }
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: UIButton) {
        if isDataInputedFor(type: "password"){
            resetPassword()
        }else{
            ProgressHUD.showFailed("Email is required")
        }
    }
    
    @IBAction func signupButtonPressed(_ sender: UIButton) {
        updateUIFor(login: sender.titleLabel?.text == "Login")
        isLogin.toggle()
    }
    @IBAction func resendEmailButtonPressed(_ sender: UIButton) {
        if isDataInputedFor(type: "password"){
            resendVerificationEmail()
        }else{
            ProgressHUD.showFailed("Email is required")
        }
    }
    
    //MARK: - setup
    private func setupTextfieldDelegates(){
        emailTextfield.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordTextfield.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        repeatTextfield.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    @objc func textFieldDidChange(_ textField: UITextField){
        updatePlaceHolderLabels(textField: textField)
    }
    
    private func setupBackgroundTap(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func backgroundTap(){
        view.endEditing(true)
    }
    
    //MARK: - Animation
    
    private func updateUIFor(login:Bool){
        loginButton.setImage(UIImage(named: login ? "loginBtn" : "registerBtn"), for: .normal)
        signupButton.setTitle(login ? "Sign up" : "Login", for: .normal)
        signupLabel.text = login ? "Don't have an account?" : "Have an account?"
        UIView.animate(withDuration: 0.5) {
            self.repeatTextfield.isHidden = login
            self.repeatPasswordLineView.isHidden = login
            self.repeatpasswordLabel.isHidden = login
        }
    }
    
    private func updatePlaceHolderLabels(textField: UITextField){
        switch textField{
        case emailTextfield:
            emailLabelOutlet.text = textField.hasText ? "Email" : ""
        case passwordTextfield:
            passwordLabelOutlet.text = textField.hasText ? "Password" : ""
        default :
            repeatpasswordLabel.text = textField.hasText ? "Repeat Password" : ""
            
        }
    }
    
    //MARK: - Helpers
    private func isDataInputedFor(type: String) -> Bool{
        switch type{
        case "login":
            return emailTextfield.text != "" && passwordTextfield.text != ""
        case "register":
            return emailTextfield.text != "" && passwordTextfield.text != "" && repeatTextfield.text != ""
        default:
            return emailTextfield.text != ""
            
        }
    }
    
    private func resetPassword(){
        FirebaseUserListener.shared.resetPasswordFor(email: emailTextfield.text!) { error in
            if error == nil{
                ProgressHUD.showSuccess("Reset link send to email")
            }else{
                ProgressHUD.showFailed(error?.localizedDescription)
            }
        }
    }
    
    
    private func resendVerificationEmail(){
        FirebaseUserListener.shared.resendVerificationEmail(email: emailTextfield.text!) { error in
            if error == nil{
                ProgressHUD.showSuccess("New verification email sent")
            }else{
                ProgressHUD.showFailed(error?.localizedDescription)
                print(error?.localizedDescription)
            }
        }
    }
    private func loginUser(){
        FirebaseUserListener.shared.loginUserWithEmail(email: emailTextfield.text!, password: passwordTextfield.text!) { error, isEmailVerified in
            if error == nil{
                if isEmailVerified{
                    self.goToApp()
                }else{
                    ProgressHUD.showFailed("Please verify email")
                    self.resendEmailButton.isHidden = false
                }
            }else{
                ProgressHUD.showFailed(error?.localizedDescription)
            }
        }
    }
    
    
    private func registerUser(){
        if passwordTextfield.text == repeatTextfield.text{
            FirebaseUserListener.shared.registerUserWith(email: emailTextfield.text!, password: passwordTextfield.text!) { error in
                if error == nil{
                    ProgressHUD.showSuccess("Verification email sent.")
                    self.resendEmailButton.isHidden = false
                }else{
                    ProgressHUD.showFailed(error?.localizedDescription)
                }
            }
        }else{
            ProgressHUD.showFailed("The passwords don't match")
        }
    }
    
    //MARK: - Navigation
    private func  goToApp(){
        let mainview = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MainApp") as! UITabBarController
        mainview.modalPresentationStyle = .fullScreen
        self.present(mainview, animated: true)
    }
    
}

