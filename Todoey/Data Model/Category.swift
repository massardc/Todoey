//
//  Category.swift
//  Todoey
//
//  Created by ClementM on 18/01/2018.
//  Copyright © 2018 ClementM. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var bgColor: String = ""
    let items = List<Item>()
}
