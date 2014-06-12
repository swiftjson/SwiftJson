//
//  ModelGenerator.swift
//  swiftin
//
//  Created by Philip Woods on 6/11/14.
//  Copyright (c) 2014 pvwoods. All rights reserved.
//

import Foundation

import Cocoa


class ModelGenerator {
    
    var modelOutput:IndentableOutput = IndentableOutput()
    var childModels:ModelGenerator[] = []
    
    var output:String {
    get {
        return modelOutput.output
    }
    }
    
    init(json:NSDictionary, className:String) {
        
        // set up the init function
        var initOutput:IndentableOutput = IndentableOutput()
        (initOutput += "init(json:NSDictionary) {").indent()
        
        // model set up
        (modelOutput += "class \(className) {").indent()
        
        // generate everything
        for (key:AnyObject, value:AnyObject) in json {
            
            var type = "AnyObject"
            
            if value.isKindOfClass(NSString) {
                type = "String"
                initOutput += "\(key) = json.objectForKey(\"\(key)\") as \(type)"
            } else if value.isKindOfClass(NSNumber) {
                type = "NSNumber"
                initOutput += "\(key) = json.objectForKey(\"\(key)\") as \(type)"
            } else if value.isKindOfClass(NSArray) {
                type = "AnyObject[]"
                initOutput += "\(key) = []"
                (initOutput += "for v:AnyObject in (json.objectForKey(\"\(key)\") as NSArray) {").indent()
                (initOutput += "\(key) += v").dedent() + "}"
            } else if value.isKindOfClass(NSDictionary) {
                var firstChar = (key.uppercaseString as NSString).substringWithRange(NSRange(location:0,length:1))
                var cn = className + firstChar + (key as NSString).substringFromIndex(1);
                childModels += ModelGenerator(json: value as NSDictionary, className: cn)
                type = cn
                initOutput += "\(key) = \(type)(json:json.objectForKey(\"\(key)\") as NSDictionary)"
                
            }
            
            modelOutput += "var \(key):\(type)"
        }
        
        // merge the init function and close everything up
        modelOutput += initOutput
        
        // close everything up
        (modelOutput.dedent() += "}").dedent() += "}"
        
        // append any child models
        for child in childModels {
            self.modelOutput += child.modelOutput
        }
        
    }
    
}