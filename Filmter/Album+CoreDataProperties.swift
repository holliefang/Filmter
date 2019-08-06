//
//  Album+CoreDataProperties.swift
//  Filmter
//
//  Created by Sihan Fang on 2019/8/4.
//  Copyright © 2019 Sihan Fang. All rights reserved.
//
//

import Foundation
import CoreData


extension Album {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Album> {
        return NSFetchRequest<Album>(entityName: "Album")
    }

    @NSManaged public var photos: [NSData]?

}
