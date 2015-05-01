//
//  ViewController.swift
//  Calculator
//
//  Created by hevil on 31.01.15.
//  Copyright (c) 2015 hevil. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var opStack: UILabel!

    var userIsInTheMiddleOfTypingOfANumber = false

    var brain = CalculatorBrain()

    var displayValue: Double? {
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set {
            if let value = newValue {
                display.text = "\(value)"
            } else {
                let result = brain.evaluateAndReportErrors()
                display.text = result.error
            }
            userIsInTheMiddleOfTypingOfANumber = false
            updateOpStackLabel()
        }
    }

    func updateOpStackLabel(showEqualsChar: Bool = false) {
        opStack.text = brain.description

        if showEqualsChar {
            opStack.text = opStack.text! + " ="
        }
    }

    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingOfANumber {
            display.text = display.text! + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingOfANumber = true
        }
        updateOpStackLabel()
    }

    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingOfANumber {
            enter()
        }

        if let operation = sender.currentTitle {
            displayValue = brain.performOperation(operation)
        }
        updateOpStackLabel(showEqualsChar: true)
    }

    @IBAction func enter() {
        userIsInTheMiddleOfTypingOfANumber = false
        if let value = displayValue {
            displayValue = brain.pushOperand(value)
        }
    }

    @IBAction func addFloatingPoint(sender: UIButton) {
        let point = sender.currentTitle!
        if display.text!.rangeOfString(point) == nil {
            appendDigit(sender)
        }
    }

    @IBAction func undo() {
        if userIsInTheMiddleOfTypingOfANumber {
            let text = display.text!
            display.text! = countElements(text) > 1 ? dropLast(text) : "0"
        } else {
            displayValue = brain.undo()
        }
    }

    @IBAction func setVariableValue() {
        brain.variableValues["m"] = displayValue
        userIsInTheMiddleOfTypingOfANumber = false
        displayValue = brain.evaluate()
        updateOpStackLabel(showEqualsChar: true)
    }

    @IBAction func enterVariable() {
        brain.pushOperand("m")
        updateOpStackLabel()
    }

    @IBAction func changeSign(sender: UIButton) {
        if userIsInTheMiddleOfTypingOfANumber {
            if display.text!.rangeOfString("−") == nil {
                display.text = "−" + display.text!
            } else {
                let secondIndexPosition = advance(display.text!.startIndex, 1)
                display.text = display.text!.substringFromIndex(secondIndexPosition)
            }
        } else {
            operate(sender)
        }
    }

    @IBAction func clear() {
        brain.clear()
        displayValue = 0
        brain.variableValues.removeValueForKey("m")
    }
}

