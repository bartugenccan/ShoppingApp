//
//  LoginViewController.swift
//  ShoppingApp
//
//  Created by Bartu Gençcan on 25.10.2022.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, AlertPresentable{
    
    // MARK: - Properties
    
    private let viewModel: LoginViewModel
    
    var activityView: UIActivityIndicatorView?
    
    enum AuthType: String {
        case signIn = "Sign In"
        case signUp = "Sign Up"
        
        init(text: String) {
            switch text {
            case "Sign In":
                self = .signIn
            case "Sign Up":
                self = .signUp
            default:
                self = .signIn
            }
        }
    }
    
    var authType: AuthType = .signIn {
        didSet {
            let buttonTitle = loginView.segmentedControl.titleForSegment(at: loginView.segmentedControl.selectedSegmentIndex)
            loginView.finishAuthButton.setTitle(buttonTitle, for: .normal)
        }
    }
    
    private lazy var loginView: LoginView = {
        let view = LoginView()
        view.delegate = self
        return view
    }()
    
    // MARK: - Lifecycle
    
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Auth"
        
        // Handling data
        viewModel.changeHandler = { change in
            switch change {
            case .didErrorOccured(let error):
                self.showAlert(title: "Error", message: error.localizedDescription)
            case .didSignUpSuccessful:
                self.showAlert(title: "Sign Up Successful!")
                self.view.backgroundColor = .white
                
            }
        }
        
        view = loginView
        loginView.segmentedControl.selectedSegmentIndex = 0
        
        viewModel.fetchRemoteConfig { isSignUpDisabled in
            self.loginView.segmentedControl.isHidden = isSignUpDisabled
        }
        
    }
}

// MARK: - Activity Indicator
extension LoginViewController {
    func showActivityIndicator(){
        activityView = UIActivityIndicatorView(style: .large)
        
        guard let activityView = activityView else {return}
        
        self.view.addSubview(activityView)
        self.view.bringSubviewToFront(activityView)
        
        activityView.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.centerY.equalTo(view.snp.centerY)
        }
        
        activityView.startAnimating()
    }
}

// MARK: - Delegate
extension LoginViewController: LoginViewDelegate {
    func didTapFinishAuthButton(sender: UIButton) {
        
        guard let email = loginView.emailTextField.text,
              let password = loginView.passwordTextField.text,
              let username = loginView.usernameTextField.text
        else {return}
        
        switch authType {
        case .signIn:
            viewModel.signIn(email: email, password: password) {
                let tabBarController = MainTabBarController()
                self.navigationController?.pushViewController(tabBarController, animated: true)
            }
            
        case .signUp:
            viewModel.signUp(username: username, email: email, password: password){
                self.loginView.emailTextField.text = ""
                self.loginView.passwordTextField.text = ""
                self.loginView.usernameTextField.text = ""
                self.loginView.segmentedControl.selectedSegmentIndex = 0
                self.didAuthChange(segmentedControl: self.loginView.segmentedControl)
            }
            
        }
    }
    
    func didAuthChange(segmentedControl: UISegmentedControl) {
        let buttonTitle = segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex)
        authType = AuthType(text: buttonTitle ?? "Sign In")
        
        switch authType {
        case .signIn:
            self.loginView.usernameTextField.isHidden = true
        case .signUp:
            self.loginView.usernameTextField.isHidden = false
        }
    }
}
