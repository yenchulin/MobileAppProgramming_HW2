//
//  ViewController.swift
//  Calculator
//
//  Created by 林晏竹 on 2017/4/15.
//  Copyright © 2017年 林晏竹. All rights reserved.
//

import UIKit
import CalculatorCore

extension Double {
    
    /// This computed property would provide a formatted string representation of this double value.
    /// For an integer value, like `2.0`, this property would be `"2"`.
    /// And for other values like `2.4`, this would be `"2.4"`.
    fileprivate var displayString: String {
        // 1. We have to check whether this double value is an integer or not.
        //    Here I subtract the value with its floor. If the result is zero, it's an integer.
        //    (Note: `floor` means removing its fraction part, 無條件捨去.
        //           `ceiling` also removes the fraction part, but it's by adding. 無條件進位.)
        let floor = self.rounded(.towardZero)  // You should check document for the `rounded` method of double
        let isInteger = self.distance(to: floor).isZero
        
        let string = String(self)
        if isInteger {
            // Okay this value is an integer, so we have to remove the `.` and tail zeros.
            // 1. Find the index of `.` first
            if let indexOfDot = string.characters.index(of: ".") {
                // 2. Return the substring from 0 to the index of dot
                //    For example: "2.0" --> "2"
                return string.substring(to: indexOfDot)
            }
        }
        // Return original string representation
        return String(self)
    }
}



class ViewController: UIViewController {

    var core = Core<Double>()
    
    @IBOutlet weak var displayLabel: UILabel!
    
    
//    var currentText = "0" {
//        didSet {
//            if currentText.characters.count > 12 {
//                let startIndex = currentText.characters.startIndex
//                let index11 = currentText.index(startIndex, offsetBy: 11)
//                self.displayLabel.text = currentText.substring(to: index11)
//            }
//        }
//    }
    
    

    var numberNeedReplace = false
    var operatorCounts = 0
    var rootOperatorIsClicked = false
    
    
    
    
    // MARK: - View Functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    
    
    @IBAction func numberButtonClicked(_ sender: UIButton) {
        let originText = self.displayLabel.text ?? "0"
        let numberClicked = sender.tag - 1000
        
        if self.numberNeedReplace {
            self.displayLabel.text = "\(numberClicked)"
        
            // Reset
            self.numberNeedReplace = false
            self.operatorCounts = 0
            
        } else {
            if originText == "0" {
                self.displayLabel.text = "\(numberClicked)"
            } else {
                self.displayLabel.text = originText.appending("\(numberClicked)")
            }
        }
    }
    
    
    
    
    @IBAction func constantButtonClicked(_ sender: UIButton) {
        switch sender.tag {
        case 1201: // e
            self.displayLabel.text = "\(M_E)"
            
        case 1202: // pi
            self.displayLabel.text = "\(Double.pi)"
            
        default:
            fatalError("Unexpected constant button: \(sender)")
        }
        self.numberNeedReplace = true
    }
    
    
    @IBAction func positiveNegativeButtonClicked(_ sender: UIButton) {
        let currentText = self.displayLabel.text ?? "0"
        
        if currentText.contains("-") {
            // Change to positive
            self.displayLabel.text = currentText.replacingOccurrences(of: "-", with: "")
            
        } else {
            // Change to negative
            self.displayLabel.text = "-" + currentText
        }
    }
    
    
    
    @IBAction func dotButtonClicked(_ sender: UIButton) {
        let currentText = self.displayLabel.text ?? "0"
        // Append the `.` to the display string only when there's no `.` in the string
        guard !currentText.contains(".") else {
            print("dot button clicked error: display text already contains '.'")
            return
        }
        // Append and re-assign the string
        self.displayLabel.text = currentText + "."
    }
    
    
    
    @IBAction func operatorButtonClicked(_ sender: UIButton) {
        
        // Check whether the operator is already clicked
        if self.operatorCounts == 0 {
        
            // Add current number into the core as a step
            let currentNumber = Double(self.displayLabel.text ?? "0")!
            if self.rootOperatorIsClicked {
                try! self.core.addStep(1 / currentNumber)
                self.rootOperatorIsClicked = false
                
            } else {
                try! self.core.addStep(currentNumber)
            }
            
            // Get and show the result
            let result = self.core.calculate()!
            self.displayLabel.text = result.displayString
            
            // Clean the display to accept user's new input
            self.numberNeedReplace = true
            
            
            switch sender.tag {
            case 1101: // Add
                try! self.core.addStep(+)
                
            case 1102: // Sub
                try! self.core.addStep(-)
                
            case 1103: // Multi
                try! self.core.addStep(*)
                
            case 1104: // Div
                try! self.core.addStep(/)
                
            case 1105: // x^y
                try! self.core.addStep(pow)
                
            case 1106: // x^(1/y)
                try! self.core.addStep(pow)
                self.rootOperatorIsClicked = true
                
            default:
                fatalError("Unknown operator button: \(sender)")
            }
        
            self.operatorCounts += 1
            
        } else {
            // do nothing remain current displayed number
        }
    }
    
    
    
    
    
    @IBAction func logOrPercentButtonClicked(_ sender: UIButton) {
        
        // Add current number into the core as a step
        let currentNumber = Double(self.displayLabel.text ?? "0")!
        
        
        switch sender.tag {
        case 1301: // log
            self.displayLabel.text = "\(log10(currentNumber))"
            
        case 1302: // %
            self.displayLabel.text = "\(currentNumber / 100)"
            
        default:
            fatalError("Unexpected button: \(sender)")
        }
        
        self.numberNeedReplace = true
    }
    
    
    
    
    
    @IBAction func ACBttonClicked(_ sender: UIButton) {
        // 1. Clean the display label
        self.displayLabel.text = "0"
        // 2. Reset the core
        self.core = Core<Double>()
        self.numberNeedReplace = false
        self.operatorCounts = 0
        self.rootOperatorIsClicked = false
    }
    
    
    @IBAction func equalButtonClicked(_ sender: UIButton) {
        // Add current number into the core as a step
        let currentNumber = Double(self.displayLabel.text ?? "0")!
        if self.rootOperatorIsClicked {
            try! self.core.addStep(1 / currentNumber)
            self.rootOperatorIsClicked = false
            
        } else {
            try! self.core.addStep(currentNumber)
        }
        
        // Get and show the result
        let result = self.core.calculate()!
        self.displayLabel.text = result.displayString
        
        // Reset the core
        self.core = Core<Double>()
        self.numberNeedReplace = true
    }
}

