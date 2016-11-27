//
//  DummySignInService.swift
//  ReactivePlayground-Final
//
//  Created by Matthew on 23/11/2016.
//  Copyright © 2016 Matthew. All rights reserved.
//

import Foundation

class DummySignInService {
    
    func signIn(withUsername username: String, andPassword password: String, completion: @escaping (Bool) -> Void) {
        let delay = 1.0
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay) {
            let success = (username == "user") && (password == "password")
            
            completion(success)
        }
    }
}
