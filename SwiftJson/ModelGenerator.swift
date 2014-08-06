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
    var childModels:[ModelGenerator] = []
    
    var output:String {
        get {
            return modelOutput.output
        }
    }
    
    init(json:JSONValue, className:String, inspectArrays:Bool) {
        
        // set up the init function
        var initOutput:IndentableOutput = IndentableOutput()
        (initOutput += "init(json:JSONValue) {").indent()
        
        // model set up
        (modelOutput += "class \(className) {").indent()
        
        // generate everything
        switch(json) {
            case .JArray(let array):
                initOutput += "// initial element was array..."
            case .JObject(let object):
                for (key, value) in object {
                    
                    var type = ""
                    
                    switch value {
                        case .JString(let value):
                            type = "String"
                            buildSetStatement(initOutput, key:key, type:type)
                        case .JNumber(let value):
                            type = "NSNumber"
                            buildSetStatement(initOutput, key:key, type:type)
                        case .JBool(let value):
                            type = "Bool"
                            buildSetStatement(initOutput, key:key, type:type)
                        case .JArray(let array):
                            if(inspectArrays && array.count >= 1) {
                                type = handleArray(array, key: key, className: className, inspectArrays: inspectArrays, io: initOutput)
                            } else {
                                initOutput += "\(key) = json[\"\(key)\"]"
                            }
                        case .JObject(let object):
                            var cn = self.buildClassName(className, suffix: key as String)
                            childModels.append(ModelGenerator(json: value, className: cn, inspectArrays:inspectArrays))
                            type = cn
                            initOutput += "\(key) = \(type)(json:json[\"\(key)\"])"
                        default:
                            type = "AnyObject"
                    }
                    
                    modelOutput += "var \(key):\(type)"
                }
            default:
                initOutput += "// unexpected type encountered"
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
    
    func handleArray(array:Array<JSONValue>, key:String, className:String, inspectArrays:Bool, io:IndentableOutput) -> String {
        
        var instantiation = "v"
        var type = "[AnyObject]"
            
        switch array[0] {
            case .JString(let value):
                type = "[String]"
            
            case .JNumber(let value):
                type = "[NSNumber]"
            
            case .JBool(let value):
                type = "[Bool]"
            
            case .JArray(let arr):
                type = "[JSONValue]"
            case .JObject(let object):
                var cn = buildClassName(className, suffix: key as String)
                childModels.append(ModelGenerator(json: array[0], className: cn, inspectArrays:inspectArrays))
                type = "[" + cn + "]"
                instantiation = "\(cn)(json:v)"
            default:
                type = "AnyObject"
        }
        
        io += "\(key) = []"
        (io += "if let xs = json[\"\(key)\"].array {").indent()
        (io += "for v in xs {").indent()
        (io += "\(key) += \(instantiation)").dedent() + "}"
        io.dedent() += "}"
        
        return type
    }
    
    func buildSetStatement(io:IndentableOutput, key:String, type:String) {
        
        let optionTypeMap = [
            "Bool": "bool",
            "NSNumber": "number",
            "String": "string"
        ]
        
        let optionDefaultValueMap = [
            "Bool": "false",
            "NSNumber": "0",
            "String": "\"\""
        ]
        
        (io += "if let value = json[\"\(key)\"].\(optionTypeMap[type]) {").indent()
        (((io += "\(key) = value").dedent()) += "} else {").indent()
        (io += "\(key) = \(optionDefaultValueMap[type])").dedent() += "}"
        
    }
    
    func buildClassName(className:String, suffix:String) -> String {
        var firstChar = (suffix as NSString).uppercaseString.substringToIndex(1)
        return className + firstChar + (suffix as NSString).substringFromIndex(1)
    }
    
}
