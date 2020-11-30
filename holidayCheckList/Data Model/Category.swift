//
//  Category.swift
//  holidayCheckList
//
//  Created by Mary Arnold on 11/24/20.
//

import Foundation
import RealmSwift

//Realm Object - dynamic var to monitor for changes in realtime
class Category: Object {
    @objc dynamic var name : String = ""
    @objc dynamic var categoryColor : String = UIColor.randomFlat().hexValue()

    
    //Creats relationship to Item
    let items = List<Item>()
}
