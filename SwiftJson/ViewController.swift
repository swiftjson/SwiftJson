//
//  ViewController.swift
//  SwiftJson
//
//  Created by Philip Woods on 6/11/14.
//  Copyright (c) 2014 pvwoods. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet var jsonScrollView:NSScrollView
    @IBOutlet var modelScrollView:NSScrollView
    @IBOutlet var classNameTextField:NSTextField
    @IBOutlet var inspectArrays:NSButton
    
    var jsonTextView : NSTextView {
        get {
            return jsonScrollView.contentView.documentView as NSTextView
        }
    }
    
    var modelTextView : NSTextView {
        get {
            return modelScrollView.contentView.documentView as NSTextView
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"onSelectGenerate:", name: "SELECTED_GENERATE", object: nil)
        jsonTextView.richText = false
        modelTextView.richText = false
                                    
    }
    
    @IBAction func onSelectGenerate(e:AnyObject) {
        
        var className = classNameTextField.stringValue.isEmpty ? "MyClass":classNameTextField.stringValue;
        
        var json = jsonTextView.textStorage.string
        var jsonData = (json as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        
        if jsonData != nil {
            
            var error: NSError?
            
            let jsonDict:AnyObject? = NSJSONSerialization.JSONObjectWithData(jsonData, options: nil, error: &error)
            
            if jsonDict {
                
                let generator:ModelGenerator = ModelGenerator(json:jsonDict! as NSDictionary, className:className, inspectArrays:inspectArrays.state == 1)
                
                modelTextView.textStorage.setAttributedString(NSAttributedString(string: generator.output))
                
            } else {
                modelTextView.textStorage.setAttributedString(NSAttributedString(string:"There was an issue parsing your JSON..."))
            }
            
        } else {
            modelTextView.textStorage.setAttributedString(NSAttributedString(string:"Couldn't encode your data..."))
        }
        
        
    }


}

