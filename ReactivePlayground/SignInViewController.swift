//
//  SignInViewController.swift
//  ReactivePlayground-Final
//
//  Created by Matthew on 23/11/2016.
//  Copyright © 2016 Matthew. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift
import enum Result.NoError

class SignInViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInFailureTextLabel: UILabel!
    @IBOutlet weak var signInButton: UIButton!
    
    private var isValidUsername: Bool {
        return usernameTextField.text!.characters.count > 3
    }
    
    private var isValidPassword: Bool {
        return passwordTextField.text!.characters.count > 3
    }
    
    private let signInService: DummySignInService = DummySignInService()
    
    // MARK: - Lift Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initially hide the failure message.
        signInFailureTextLabel.isHidden = true
        
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        usernameTextField.reactive.continuousTextValues.map({
            text in
            
            return text!.characters.count
        }).filter({
            characterCount in
            
            return characterCount > 3
        }).observeValues {
            characterCount in
            
            print(characterCount ?? "")
        }
        
        let validUsernameSignal = usernameTextField.reactive.continuousTextValues.map({
            text in
            
            return self.isValidUsername
        })
            
        validUsernameSignal.map({
            isValidUsername in
            
            return isValidUsername ? UIColor.clear : UIColor.yellow
        }).observeValues {
            backgroundColor in
            
            self.usernameTextField.backgroundColor = backgroundColor
        }
        
        let validPasswordSignal = passwordTextField.reactive.continuousTextValues.map({
            text in
            
            return self.isValidPassword
        })
            
        validPasswordSignal.map({
            isValidPassword in
            
            return isValidPassword ? UIColor.clear : UIColor.yellow
        }).observeValues {
            backgroundColor in
            
            self.passwordTextField.backgroundColor = backgroundColor
        }
        
        let signUpActiveSignal = Signal.combineLatest(validUsernameSignal, validPasswordSignal).map {
            (isValidUsername, isValidPassword) in
            
            return isValidUsername && isValidPassword
        }
        
        let signInButtonEnabledProperty = Property(initial: false, then: signUpActiveSignal)
        
        let action = Action<(String, String), Bool, NoError>(enabledIf: signInButtonEnabledProperty) {
            (username, password) in
            
            return self.createSignInSignalProducer(withUsername: username, andPassword: password)
        }
        
        action.values.observeValues {
            success in
            
            self.signInFailureTextLabel.isHidden = success
            
            if success {
                self.performSegue(withIdentifier: "signInSuccess", sender: self)
            }
        }
        
        signInButton.reactive.pressed = CocoaAction<UIButton>(action) {
            _ in
            
            (self.usernameTextField.text!, self.passwordTextField.text!)
        }
    }
    
    private func createSignInSignalProducer(withUsername username: String, andPassword password: String) -> SignalProducer<Bool, NoError> {
        let (signInSignal, observer) = Signal<Bool, NoError>.pipe()
        
        let signInSignalProducer = SignalProducer<Bool, NoError>(signal: signInSignal)
        
        self.signInService.signIn(
            withUsername: self.usernameTextField.text!, andPassword: self.passwordTextField.text!
        ) {
            success in
            
            observer.send(value: success)
            observer.sendCompleted()
        }
        
        return signInSignalProducer
    }
}

