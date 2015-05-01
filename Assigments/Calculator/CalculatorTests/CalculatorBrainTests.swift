//
//  CalculatorBrainTests.swift
//  Calculator
//
//  Created by hevil on 08.02.15.
//  Copyright (c) 2015 hevil. All rights reserved.
//
import XCTest

class CalculatorBrainTests: XCTestCase {
   var brain = CalculatorBrain()

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        brain.clear()
        super.tearDown()
    }

    func testPushOperand() {
        let operand = brain.pushOperand(123)!
        XCTAssert(operand == 123, "Wrong operator value: \(operand)")
    }

    func testPerformBinaryOperation() {
        brain.pushOperand(1)
        brain.pushOperand(2)
        let result = brain.performOperation("+")!

        XCTAssert(result == 3, "Wrong result: \(result)")
    }

    func testPerformBinaryOperationWithMissedOperand() {
        brain.pushOperand(1)
        let result = brain.performOperation("+")

        XCTAssert(result == nil, "Wrong result: \(result)")
    }

    func testPerformUnaryOperation() {
        brain.pushOperand(1)
        let result = brain.performOperation("±")!

        XCTAssert(result == -1, "Wrong result: \(result)")
    }

    func testPerformUnaryOperationWithMissedOperand() {
        let result = brain.performOperation("±")

        XCTAssert(result == nil, "Wrong result: \(result)")
    }

    func testPerformNullaryOperation() {
        let result = brain.performOperation("π")!

        XCTAssert(result == M_PI, "Wrong result: \(result)")
    }

    func testPerformUnknownOperation() {
        brain.pushOperand(1)
        let result = brain.performOperation("zzzz")!

        XCTAssert(result == 1, "Wrong result: \(result)")
    }

    func testPerformComplexOperation() {
        brain.pushOperand(1)
        brain.pushOperand(2)
        brain.performOperation("+")
        brain.pushOperand(3)
        let result = brain.performOperation("×")! // (1 + 2) * 3 = 9

        XCTAssert(result == 9, "Wrong result: \(result)")
    }

    func testPushVariable() {
        let result = brain.pushOperand("m")
        XCTAssert(result == nil, "should return nil by default (\(result) != nil)")

        brain.variableValues["m"] = 123
        let result2 = brain.evaluate()
        XCTAssert(result2 == 123, "should return the variable value (\(result) != 123)")

        brain.variableValues.removeValueForKey("m")
        let result3 = brain.evaluate()
        XCTAssert(result3 == nil, "should return nil after the value was removed (\(result) != nil)")
    }

    func testDescriptionForUnaryOperation() {
        brain.pushOperand(10)
        brain.performOperation("cos")

        XCTAssert(brain.description == "cos(10.0)", "Wrong description: \(brain.description)")
    }

    func testDescriptionForBinaryOperation() {
        brain.pushOperand(3)
        brain.pushOperand(5)
        brain.performOperation("−")

        XCTAssert(brain.description == "3.0 − 5.0", "Wrong description: \(brain.description)")
    }

    func testDescriptionForBinaryOperationWithMissedOperand() {
        brain.pushOperand(3)
        brain.performOperation("+")

        XCTAssert(brain.description == "? + 3.0", "Wrong description: \(brain.description)")
    }

    func testDescriptionForOperand() {
        brain.pushOperand(23.5)

        XCTAssert(brain.description == "23.5", "Wrong description: \(brain.description)")
    }

    func testDescriptionForNullaryOperation() {
        brain.pushOperand("π")

        XCTAssert(brain.description == "π", "Wrong description: \(brain.description)")
    }

    func testDescriptionForVariable() {
        brain.pushOperand("m")

        XCTAssert(brain.description == "m", "Wrong description: \(brain.description)")
    }

    func testDescriptionForComplexExpression() {
        brain.pushOperand(10)
        brain.performOperation("√")
        brain.pushOperand(3)
        brain.performOperation("+")

        XCTAssert(brain.description == "√(10.0) + 3.0", "Wrong description: \(brain.description)")
    }

    func testDescriptionForComplexExpression2() {
        brain.pushOperand(3)
        brain.pushOperand(5)
        brain.performOperation("+")
        brain.performOperation("√")

        XCTAssert(brain.description == "√(3.0 + 5.0)", "Wrong description: \(brain.description)")
    }

    func testDescriptionForComplexExpression3() {
        brain.pushOperand(3)
        brain.pushOperand(5)
        brain.pushOperand(4)
        brain.performOperation("+")
        brain.performOperation("+")

        XCTAssert(brain.description == "3.0 + 5.0 + 4.0", "Wrong description: \(brain.description)")
    }

    func testDescriptionForComplexExpression4() {
        brain.pushOperand(3)
        brain.pushOperand(5)
        brain.performOperation("√")
        brain.performOperation("+")
        brain.performOperation("√")
        brain.pushOperand(6)
        brain.performOperation("÷")

        XCTAssert(brain.description == "√(3.0 + √(5.0)) ÷ 6.0", "Wrong description: \(brain.description)")
    }

    func testDescriptionForMultipleCompleteExpressions() {
        brain.pushOperand(3)
        brain.pushOperand(5)
        brain.performOperation("+")
        brain.performOperation("√")
        brain.performOperation("π")
        brain.performOperation("cos")

        XCTAssert(brain.description == "√(3.0 + 5.0), cos(π)", "Wrong description: \(brain.description)")
    }

    func testDescriptionWithOperationPrecedence() {
        brain.pushOperand(3)
        brain.pushOperand(5)
        brain.pushOperand(4)
        brain.performOperation("+")
        brain.performOperation("×")
        
        XCTAssert(brain.description == "3.0 × (5.0 + 4.0)", "Wrong description: \(brain.description)")
    }

    // evaluateAndReportErrors()

    func testEvaluateAndReportErrorsForEmptyStack() {
        let result = brain.evaluateAndReportErrors()
        XCTAssert(result.error == nil, "Wrong error message: \(result.error)")
    }

    func testEvaluateAndReportErrorsForBinaryOperaiontMissedFirstOperand() {
        brain.performOperation("+")
        let result = brain.evaluateAndReportErrors()

        XCTAssert(result.error == "Not enough operands", "Wrong error message: \(result.error)")
    }

    func testEvaluateAndReportErrorsForBinaryOperaiontMissedSecondOperand() {
        brain.pushOperand(3)
        brain.performOperation("+")
        let result = brain.evaluateAndReportErrors()

        XCTAssert(result.error == "Not enough operands", "Wrong error message: \(result.error)")
    }

    func testEvaluateAndReportErrorsForUnaryOperaiontMissedOperand() {
        brain.performOperation("cos")
        let result = brain.evaluateAndReportErrors()

        XCTAssert(result.error == "Not enough operands", "Wrong error message: \(result.error)")
    }

    func testEvaluateAndReportErrorsForBinaryOperaiontDivideByZero() {
        brain.pushOperand(3)
        brain.pushOperand(0)
        brain.performOperation("÷")
        let result = brain.evaluateAndReportErrors()

        XCTAssert(result.error == "Divide by zero", "Wrong error message: \(result.error)")
    }

    func testEvaluateAndReportErrorsForUnaryOperationSqureRoot() {
        brain.pushOperand(-4)
        brain.performOperation("√")
        let result = brain.evaluateAndReportErrors()

        XCTAssert(result.error == "Sqrt of negative number", "Wrong error message: \(result.error)")
    }

    func testEvaluateAndReportErrorsUnsetVariable() {
        brain.pushOperand("m")
        let result = brain.evaluateAndReportErrors()

        XCTAssert(result.error == "Variable m is unset", "Wrong error message: \(result.error)")
    }
}
