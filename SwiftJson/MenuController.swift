//
//  MenuController.swift
//  SwiftJson
//
//  Created by Philip Woods on 6/11/14.
//  Copyright (c) 2014 pvwoods. All rights reserved.
//

import Foundation
import Cocoa

class MenuController : NSMenu {
    
    @IBAction func onSelectGenerate(e:NSEvent) {
        NSNotificationCenter.defaultCenter().postNotificationName("SELECTED_GENERATE", object: nil)
    }
    
}