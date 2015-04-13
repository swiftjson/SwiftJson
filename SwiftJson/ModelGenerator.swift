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
    
    init(json:JSON, className:String, inspectArrays:Bool) {
        
        // set up the init function
        var initOutput:IndentableOutput = IndentableOutput()
        (initOutput += "init(json:JSON) {").indent()
        
        // model set up
        (modelOutput += "class \(className) {").indent()
        
        // generate everything

        if let array = json.array {
            initOutput += "// initial element was array..."
        }
        else if let object = json.dictionary {
            for (key, value) in object {
                
                var type = ""
                
                var js : JSON = value as JSON
                
                if let val = js.string {
                    type = "String"
                    buildSetStatement(initOutput, key: key, type: type)
                } else if let val = js.number {
                    type = "NSNumber"
                    buildSetStatement(initOutput, key: key, type: type)
                } else if let val = js.bool {
                    type = "Bool"
                    buildSetStatement(initOutput, key: key, type: type)
                } else if let array = js.array {
                    if(inspectArrays && array.count >= 1) {
                        type = handleArray(array, key: key, className: className, inspectArrays: inspectArrays, io: initOutput)
                    } else {
                        initOutput += "\(key) = json[\"\(key)\"]"
                    }
                } else if let object = (value as? JSON)?.object {
                    var cn = self.buildClassName(className, suffix: key as String)
                    childModels.append(ModelGenerator(json: value, className: cn, inspectArrays:inspectArrays))
                    type = cn
                    initOutput += "\(key) = \(type)(json:json[\"\(key)\"])"

                } else {
                    type = "AnyObject"
                }
                
                modelOutput += "var \(key):\(type)"
            }
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
    
    func handleArray(array:Array<JSON>, key:String, className:String, inspectArrays:Bool, io:IndentableOutput) -> String {
        
        var instantiation = "v"
        var type = "[AnyObject]"
        
        var js = (array[0] as JSON);
        
        if let val = js.string {
            type = "String"
            
        } else if let val = js.number {
            type = "NSNumber"
            
        } else if let val = js.bool {
            type = "Bool"
        } else if let array = js.array {
            type = "[JSON]"
        } else if let object = (array[0] as? JSON)?.object {
            var cn = buildClassName(className, suffix: key as String)
            childModels.append(ModelGenerator(json: array[0], className: cn, inspectArrays:inspectArrays))
            type = "[" + cn + "]"
            instantiation = "\(cn)(json:v)"
        } else {
            type = "AnyObject"
        }
        
        io += "\(key) = []"
        (io += "if let xs = json[\"\(key)\"].array {").indent()
        (io += "for v in xs {").indent()
        (io += "\(key).append(\(instantiation))").dedent() + "}"
        io.dedent() += "}"
        
        return type
    }
    
    func buildSetStatement(io:IndentableOutput, key:String, type:String) {
        
        let optionTypeMap : [String: String] = [
            "Bool": "bool",
            "NSNumber": "number",
            "String": "string"
        ]
        
        let optionDefaultValueMap : [String : String] = [
            "Bool": "false",
            "NSNumber": "0",
            "String": "\"\""
        ]
        
        let typeMap : String = (optionTypeMap[type] as! String?)!;
        let defaultValueMap : String = (optionDefaultValueMap[type] as! String?)!;
        
        
        (io += "if let value = json[\"\(key)\"].\(typeMap) {").indent()
        
        (((io += "\(key) = value").dedent()) += "} else {").indent()
        
        (io += "\(key) = \(defaultValueMap)").dedent() += "}"
        
    }
    
    func buildClassName(className:String, suffix:String) -> String {
        let index: String.Index = advance(suffix.startIndex, 1)
        var firstChar = (suffix as NSString).uppercaseString.substringToIndex(index)
        return className + firstChar + (suffix as NSString).substringFromIndex(1)
    }
    
}
