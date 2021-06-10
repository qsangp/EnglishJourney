//
//  RealmModel.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 09/06/2021.
//

import Foundation
import RealmSwift

class UserInfo: Object {
    @objc dynamic var name = ""
    @objc dynamic var email = ""
    @objc dynamic var id = 0
    @objc dynamic var profileImage = ""
    
    convenience init(name: String, email: String, id: Int, profileImage: String) {
        self.init()
        self.name = name
        self.email = email
        self.id = id
        self.profileImage = profileImage
    }

    override class func primaryKey() -> String? {
        return "email"
    }
}

class CardCategoryRealm: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var numOfLesson: Int = 0
    @objc dynamic var id: Int = 0
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
