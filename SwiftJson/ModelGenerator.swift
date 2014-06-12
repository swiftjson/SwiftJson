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
    
    init(json:NSDictionary, className:String, inspectArrays:Bool) {
        
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
                
                var array:NSArray = value as NSArray;
                var instantiation = "v"
                type = "AnyObject[]"
                
                if inspectArrays && array.count > 0 {
                    var firstVal:AnyObject = array.objectAtIndex(0)
                    if firstVal.isKindOfClass(NSString) {
                        type = "String[]"
                        instantiation += " as String"
                    } else if firstVal.isKindOfClass(NSNumber) {
                        type = "NSNumber[]"
                        instantiation += " as NSNumber"
                    } else if firstVal.isKindOfClass(NSDictionary) {
                        var cn = self.buildClassName(className, suffix: key as String)
                        childModels += ModelGenerator(json: firstVal as NSDictionary, className: cn, inspectArrays:inspectArrays)
                        type = cn + "[]"
                        instantiation = cn + "(json:v as NSDictionary)"
                    }
                }
                
                initOutput += "\(key) = []"
                (initOutput += "for v:AnyObject in (json.objectForKey(\"\(key)\") as NSArray) {").indent()
                (initOutput += "\(key) += \(instantiation)").dedent() + "}"
                
            } else if value.isKindOfClass(NSDictionary) {
                
                var cn = self.buildClassName(className, suffix: key as String)
                childModels += ModelGenerator(json: value as NSDictionary, className: cn, inspectArrays:inspectArrays)
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
    
    func buildClassName(className:String, suffix:String) -> String {
        var firstChar = (suffix as NSString).uppercaseString.substringToIndex(1)
        return className + firstChar + (suffix as NSString).substringFromIndex(1)
    }
    
}