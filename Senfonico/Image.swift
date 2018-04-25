//
//  Image.swift
//  Senfonico
//
//  Created by Emre HAVAN on 24.04.2018.
//  Copyright © 2018 Emre HAVAN. All rights reserved.
//

import SwiftyJSON

class Image {
    let farm: String
    let server: String
    let id: String
    let secret: String
    var imageString: String
    
    init(userJson: JSON, index: Int) {
        self.farm = userJson["photos"]["photo"][index]["farm"].stringValue
        self.server = userJson["photos"]["photo"][index]["server"].stringValue
        self.id = userJson["photos"]["photo"][index]["id"].stringValue
        self.secret = userJson["photos"]["photo"][index]["secret"].stringValue
        self.imageString = ""
    }
    
    deinit {
        print("wearedonefam")
    }
}
