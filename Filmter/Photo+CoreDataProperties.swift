//
//  Photo+CoreDataProperties.swift
//  Filmter
//
//  Created by Sihan Fang on 2019/8/4.
//  Copyright © 2019 Sihan Fang. All rights reserved.
//
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var image: NSData?
    @NSManaged public var id: Int32

}
