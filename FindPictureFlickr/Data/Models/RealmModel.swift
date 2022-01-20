//
//  RealmModel.swift
//  FindPictureFlickr
//
//  Created by Rita on 17.01.2022.
//

import UIKit
import RealmSwift

class RealmModel: Object {
    @objc dynamic var title = ""
    @objc dynamic var urlImage = ""
    
    convenience init(title: String, urlImage: String) {
        self.init()
        self.title = title
        self.urlImage = urlImage
    }
    
}
