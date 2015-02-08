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

    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingOfANumber {
            display.text = display.text! + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingOfANumber = true
        }
        opStack.text = "\(brain.opStackDescription)"
    }

    @IBAction func addFloatingPoint(sender: UIButton) {
        let point = sender.currentTitle!
        if display.text!.rangeOfString(point) == nil {
            appendDigit(sender)
        }
    }

    @IBAction func backspace() {
        if countElements(display.text!) > 1 {
            display.text! = dropLast(display.text!)
        } else {
            displayValue = 0
        }
    }

    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingOfANumber {
            enter()
        }

        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation) {
                displayValue = result
            } else {
                displayValue = nil
            }
        }
        opStack.text = opStack.text! + " ="
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

    @IBAction func enter() {
        userIsInTheMiddleOfTypingOfANumber = false
        if let value = displayValue {
            if let result = brain.pushOperand(value) {
                displayValue = result
            } else {
                displayValue = nil
            }
        }
    }

    @IBAction func clear() {
        brain.clear()
        displayValue = 0
    }

    var displayValue: Double? {
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set {
            if let value = newValue {
                display.text = "\(value)"
            } else {
                display.text = "ERR"
            }
            userIsInTheMiddleOfTypingOfANumber = false
            opStack.text = "\(brain.opStackDescription)"
        }
    }
}

