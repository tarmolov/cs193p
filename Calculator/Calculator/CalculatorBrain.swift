//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by hevil on 31.01.15.
//  Copyright (c) 2015 hevil. All rights reserved.
//

import Foundation

class CalculatorBrain {
    private enum Op: Printable {
        case Operand(Double)
        case Variable(String)
        case UnaryOperation(String, Double -> Double, (Double -> String?)?)
        case BinaryOperation(String, Int, (Double, Double) -> Double, ((Double, Double) -> String?)?)
        case NullaryOperation(String, () -> Double)

        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .Variable(let variable):
                    return "\(variable)"
                case .UnaryOperation(let symbol, _, _):
                    return symbol
                case .BinaryOperation(let symbol, _, _, _):
                    return symbol
                case .NullaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }

    enum OpResult {
        case Value(Double?)
        case Error(String?)

        var value: Double? {
            switch self {
            case .Value(let value): return value
            case .Error(_): return nil
            }
        }

        var error: String? {
            switch self {
            case .Value(_): return nil
            case .Error(let error): return error
            }
        }
    }

    private var opStack = [Op]()

    private var knowsOps = [String: Op]()

    var variableValues = [String: Double]()

    var description: String {
        return join(", ", getExprissions(opStack))
    }

    init() {
        func learnOp(op: Op) {
            knowsOps[op.description] = op
        }
        let multiplicativePrecedence = 150
        let additivePrecedence = 140

        learnOp(Op.BinaryOperation("×", multiplicativePrecedence, *, nil))
        learnOp(Op.BinaryOperation("÷", multiplicativePrecedence, { $1 / $0 }, {(op1, op2) in op1 == 0 ? "Divide by zero" : nil }))
        learnOp(Op.BinaryOperation("+", additivePrecedence, +, nil))
        learnOp(Op.BinaryOperation("−", additivePrecedence, { $1 - $0 }, nil))
        learnOp(Op.UnaryOperation("√", sqrt, { $0 < 0 ? "Sqrt of negative number" : nil }))
        learnOp(Op.UnaryOperation("sin", sin, nil))
        learnOp(Op.UnaryOperation("cos", cos, nil))
        learnOp(Op.UnaryOperation("±", { -$0 }, nil))
        learnOp(Op.NullaryOperation("π") { M_PI })
    }

    private func getExprissions(ops: [Op]) -> [String] {
        let (result, _, remainingOps) = getExpression(ops)
        return remainingOps.isEmpty ? [result] : getExprissions(remainingOps) + [result]
    }

    private func getExpression(ops: [Op]) -> (result: String, lastPrecedence: Int, remainingOps: [Op]) {
        let maxPrecedence = Int.max

        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return ("\(operand)", maxPrecedence, remainingOps)
            case .Variable(let variable):
                return (variable, maxPrecedence, remainingOps)
            case .UnaryOperation(let symbol, _, _):
                let operandEvaluation = getExpression(remainingOps)
                return ("\(symbol)(\(operandEvaluation.result))", maxPrecedence, operandEvaluation.remainingOps)
            case .BinaryOperation(let symbol, let precedence, _, _):
                let op1Evaluation = getExpression(remainingOps)
                let op2Evaluation = getExpression(op1Evaluation.remainingOps)
                let op1 = op1Evaluation.lastPrecedence < precedence ? "(\(op1Evaluation.result))" : op1Evaluation.result
                let op2 = op2Evaluation.lastPrecedence < precedence ? "(\(op2Evaluation.result))" : op2Evaluation.result
                return ("\(op2) \(symbol) \(op1)", precedence, op2Evaluation.remainingOps)
            case .NullaryOperation(let symbol, _):
                return (symbol, maxPrecedence, remainingOps)
            }
        }
        return ("?", maxPrecedence, ops)
    }

    func evaluate() -> Double? {
        let (result, remainder) = evaluateAndReportErrors(opStack)
        return result.value
    }

    func evaluateAndReportErrors() -> OpResult {
        let (result, remainder) = evaluateAndReportErrors(opStack)
        return result
    }

    private func evaluateAndReportErrors(ops: [Op]) -> (result: OpResult, remainingOps: [Op]) {
        if ops.isEmpty {
            return (OpResult.Value(nil), ops)
        }

        var remainingOps = ops
        let op = remainingOps.removeLast()
        switch op {
        case .Operand(let operand):
            return (OpResult.Value(operand), remainingOps)
        case .Variable(let variable):
            if let value = variableValues[variable] {
                return (OpResult.Value(value), remainingOps)
            } else {
                return (OpResult.Error("Variable \(variable) is unset"),remainingOps)
            }
        case .UnaryOperation(_, let operation, let checker):
            let operandEvaluation = evaluateAndReportErrors(remainingOps)
            if let operand = operandEvaluation.result.value {
                if let error = checker?(operand) {
                    return (OpResult.Error(error), operandEvaluation.remainingOps)
                } else {
                    return (OpResult.Value(operation(operand)), operandEvaluation.remainingOps)
                }
            } else {
                let error = operandEvaluation.result.error
                let message = error != nil ? error : "Not enough operands"
                return (OpResult.Error(message), operandEvaluation.remainingOps)
            }
        case .BinaryOperation(_, _, let operation, let checker):
            let op1Evaluation = evaluateAndReportErrors(remainingOps)

            if let error1 = op1Evaluation.result.error {
                return (OpResult.Error(error1), op1Evaluation.remainingOps)
            }

            if let operand1 = op1Evaluation.result.value {
                let op2Evaluation = evaluateAndReportErrors(op1Evaluation.remainingOps)

                if let error2 = op1Evaluation.result.error {
                    return (OpResult.Error(error2), op2Evaluation.remainingOps)
                }

                if let operand2 = op2Evaluation.result.value {
                    if let error = checker?(operand1, operand2) {
                        return (OpResult.Error(error), op2Evaluation.remainingOps)
                    } else {
                        return (OpResult.Value(operation(operand1, operand2)), op2Evaluation.remainingOps)
                    }
                } else {
                    return (OpResult.Error("Not enough operands"), op2Evaluation.remainingOps)
                }
            } else {
                return (OpResult.Error("Not enough operands"), op1Evaluation.remainingOps)
            }
        case .NullaryOperation(_, let operation):
            return (OpResult.Value(operation()), remainingOps)
        }
    }

    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }

    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.Variable(symbol))
        return evaluate()
    }

    func performOperation(symbol: String) -> Double? {
        if let operation = knowsOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }

    func undo() -> Double? {
        if !opStack.isEmpty {
            opStack.removeLast()
        }
        return evaluate()
    }

    func clear() {
        opStack.removeAll()
    }
}