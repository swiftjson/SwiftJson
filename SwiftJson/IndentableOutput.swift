//
//  IndentableOutput.swift
//  swiftin
//
//  Created by Philip Woods on 6/11/14.
//  Copyright (c) 2014 pvwoods. All rights reserved.
//

import Foundation

enum OutputInstructionType:Int {
    case Indent
    case PrintLine
}

struct OutputInstruction {
    var type:OutputInstructionType
    var data:AnyObject
    
    init(iType:OutputInstructionType, iData:AnyObject) {
        self.type = iType
        self.data = iData
    }
}

class IndentableOutput {
    
    let spacesPerIndent:Int = 4
    
    var _indentation:Int = 0
    var indentation:Int {
    get {
        return _indentation
    }
    set {
        let i:Int = newValue - _indentation;
        _indentation = newValue
        rawOutput.append(OutputInstruction(iType: OutputInstructionType.Indent, iData: i))
    }
    }
    var tabs:String {
    get {
        return " "  * (indentation * spacesPerIndent)
    }
    }
    
    var output:String = ""
    var rawOutput:[OutputInstruction] = []
    
    func addLineToOutput(l:String) -> IndentableOutput {
        rawOutput.append(OutputInstruction(iType: OutputInstructionType.PrintLine, iData: l))
        output += tabs + l + "\n"
        return self
    }
    
    func indent() -> IndentableOutput {
        self.indentation++
        return self
    }
    
    func dedent() -> IndentableOutput {
        self.indentation--
        return self
    }
    
}

 func + (left:IndentableOutput, right:IndentableOutput) -> IndentableOutput {
    
    for instruction in right.rawOutput {
        switch instruction.type {
        case OutputInstructionType.Indent:
            left.indentation += instruction.data as! Int
        case OutputInstructionType.PrintLine:
            left.addLineToOutput(instruction.data as! String)
        }
    }
    
    return left
}

 func += (left:IndentableOutput, right:IndentableOutput) -> IndentableOutput {
    return left + right
}

 func + (left:IndentableOutput, right:String) -> IndentableOutput {
    left.addLineToOutput(right)
    return left
}

 func += (left:IndentableOutput, right:String) -> IndentableOutput {
    left.addLineToOutput(right)
    return left
}

 func += (left:IndentableOutput, right:[IndentableOutput]) -> IndentableOutput {
    for io in right {
        left += io
    }
    return left
}

 func * (left: String, right: Int) -> String {
    var output = left
    for i in 0...right {
        output += left
    }
    return output
}
