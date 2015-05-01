//
//  ViewControllerTests.swift
//  Calculator
//
//  Created by hevil on 17.02.15.
//  Copyright (c) 2015 hevil. All rights reserved.
//

import UIKit
import XCTest

class ViewControllerTests: XCTestCase {
    var viewController:ViewController!
    var buttons:[String:UIButton]!

    override func setUp() {
        super.setUp()

        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType))
        viewController = storyboard.instantiateViewControllerWithIdentifier("ViewController") as ViewController

        let dummy = viewController.view // force loading subviews and setting outlets
        viewController.viewDidLoad()

        buttons = viewController.view.subviews.reduce([String:UIButton]()) {
            (res, obj) in
            var result = res
            if let button = obj as? UIButton {
                if let title = button.currentTitle {
                    result[button.currentTitle!] = button
                }

            }
            return result
        }
    }

    override func tearDown() {
        super.tearDown()
        buttons = nil
        viewController = nil
    }

    func pressButton(symbol:String) {
        buttons[symbol]!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
    }

    func testOutletsDefaultValues() {
        XCTAssert(viewController.display.text! == "0", "Wrong value for display text. Actual value: \(viewController.display.text!)")
        XCTAssert(viewController.opStack.text! == "?", "Wrong value for opStack text. Actual value: \(viewController.opStack.text!)")
    }

    func testNumberInput() {
        pressButton("1")
        pressButton("2")

        let text = viewController.display.text!
        XCTAssert(text == "12", "Inccorect number in the label. Actual value: \(text)")
    }

    func testBinaryOperations() {
        pressButton("1")
        pressButton("0")
        pressButton("⏎")
        pressButton("2")
        pressButton("⏎")
        pressButton("+") // 10 + 2 = 12
        pressButton("3")
        pressButton("×") // 12 * 3 = 36


        let text = viewController.display.text!
        XCTAssert(text == "36.0", "Inccorect result for applying binary operations. Actual value: \(text)")
    }

    func testUnaryOperations() {
        pressButton("9")
        pressButton("√")
        pressButton("±") // -sqrt(9)

        let text = viewController.display.text!
        XCTAssert(text == "-3.0", "Inccorect result for applying unary operations. Actual value: \(text)")
    }

    func testNullaryOperations() {
        pressButton("π")

        let text = viewController.display.text!
        XCTAssert(text == "\(M_PI)", "Inccorect result for applying nullary operations. Actual value: \(text)")
    }

    func testOperationFailure() {
        pressButton("1")
        pressButton("+") // 1 + = ERROR

        let text = viewController.display.text!
        XCTAssert(text == "Not enough operands", "Inccorect result for error. Actual value: \(text)")
    }

    func testFloatingPoint() {
        pressButton("1")
        pressButton(".")
        pressButton("5")

        let text = viewController.display.text!
        XCTAssert(text == "1.5", "Inccorect result with floating point. Actual value: \(text)")
    }

    func testClearButton() {
        pressButton("1")
        pressButton("⏎")
        pressButton("2")
        pressButton("⏎")
        pressButton("c")

        let text = viewController.display.text!
        XCTAssert(text == "0.0", "Clear button doesn't work properly. Label has a wrong value: \(text)")
    }

    func testUndoButtonAsBackspace() {
        pressButton("1")
        pressButton("2")
        pressButton("3")
        pressButton("←")
        pressButton("←")
        pressButton("←")
        pressButton("←")

        let text = viewController.display.text!
        XCTAssert(text == "0", "Backspace should remove digits. Label has a wrong value: \(text)")
    }

    func testUndoButton() {
        pressButton("1")
        pressButton("⏎")
        pressButton("2")
        pressButton("⏎")
        pressButton("+")
        pressButton("←")

        let text = viewController.display.text!
        XCTAssert(text == "2.0", "Undo should work properly. Label has a wrong value: \(text)")
    }

    func testVariablesButtons() {
        pressButton("7")
        pressButton("⏎")
        pressButton("M")
        pressButton("+")
        pressButton("√")

        let text = viewController.display.text!
        XCTAssert(text == "Variable m is unset", "Label should be blank. Label has a wrong value: \(text)")

        pressButton("9")
        pressButton("→M")
        println(viewController.opStack.text)
        println(viewController.display.text)

        let text2 = viewController.display.text!
        XCTAssert(text2 == "4.0", "Inccorect result. Label has a wrong value: \(text2)")

        pressButton("1")
        pressButton("4")
        pressButton("⏎")
        pressButton("+")

        let text3 = viewController.display.text!
        XCTAssert(text3 == "18.0", "Inccorect result. Label has a wrong value: \(text3)")

    }
}
