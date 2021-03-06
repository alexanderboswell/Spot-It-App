//
//  User.swift
//  CarFinder
//
//  Created by alexander boswell on 5/31/17.
//  Copyright © 2017 alexander boswell. All rights reserved.
//

import Foundation
import FirebaseDatabase

class User {
    
    // MARK: Class Variables
    var email: String!
    
    var id: String!
    
    var name: String!
    
    var profileImageURL: String!
    
    var imageName: String!
    
    var ref : FIRDatabaseReference?
    
    // MARK: Initizalition
    init(userEmail: String, userID: String, userName: String, profileImageURL: String, imageName: String) {
        self.email = userEmail
        self.id = userID
        self.name = userName
        self.profileImageURL = profileImageURL
        self.imageName = imageName
    }
    init (snapshot: FIRDataSnapshot) {
        ref = snapshot.ref
        
        let data = snapshot.value as! Dictionary<String, Any>

        self.email = data["email"] as? String
        self.name = data["name"] as? String
        self.profileImageURL = data["profileImageURL"] as? String
        self.imageName = data["imageName"] as? String
    }
    
}
