//
//  ViewController.swift
//  MathSwiftDemo
//
//  Created by Enyan HUANG on 26/10/2016.
//
//

import UIKit
import MathSwift

class ViewController: UIViewController {

    @IBOutlet var inputElements: [UITextField]!
    @IBOutlet var outputElements: [UITextField]!
    
    var inputMatrix = Matrix.zerosWithRows(3, columns: 3)
    var inputMatrix2 = Matrix.identityWithSize(3)
    var outputMatrix = Matrix.zerosWithRows(3, columns: 3)
    var lastOperator = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func inputDidEnd() {
        let seq = self.inputElements.enumerated()
        for (i, tf) in seq {
            self.inputMatrix[i/3, i%3] = (Double(tf.text ?? "0") ?? 0).toMatrix()
        }
        print(self.inputMatrix)
    }

    func updateInputElements() {
        let seq = self.inputElements.enumerated()
        for (i, tf) in seq {
            tf.text = "\(self.inputMatrix[i/3, i%3].toDouble()!)"
        }
    }
    
    func updateOutputElements() {
        let seq = self.outputElements.enumerated()
        for (i, tf) in seq {
            tf.text = String(format: "%.2f", self.outputMatrix[i/3, i%3].toDouble()!)
        }
    }
    
    @IBAction func plusDidPress() {
        self.view.endEditing(false)
        self.inputMatrix2 = self.inputMatrix
        self.inputMatrix = Matrix.zerosWithRows(3, columns: 3)
        self.lastOperator = "+"
        updateInputElements()
    }

    @IBAction func minusDidPress() {
        self.view.endEditing(false)
        self.inputMatrix2 = self.inputMatrix
        self.inputMatrix = Matrix.zerosWithRows(3, columns: 3)
        self.lastOperator = "-"
        updateInputElements()
    }
    
    @IBAction func transposeDidPress() {
        self.view.endEditing(false)
        self.outputMatrix = self.inputMatrix.transpose
        updateOutputElements()
        self.lastOperator = ""
    }
    
    @IBAction func detDidPress() {
        self.view.endEditing(false)
        let seq = self.outputElements.enumerated()
        for (_, tf) in seq {
            tf.text = ""
        }
        self.outputElements[4].text = String(format: "%.2f", self.inputMatrix.determinant)
        self.lastOperator = ""
    }
    
    @IBAction func multiplyDidPress() {
        self.view.endEditing(false)
        self.inputMatrix2 = self.inputMatrix
        self.inputMatrix = Matrix.zerosWithRows(3, columns: 3)
        self.lastOperator = "*"
        updateInputElements()
    }
    
    @IBAction func dotMultiplyDidPress() {
        self.view.endEditing(false)
        self.inputMatrix2 = self.inputMatrix
        self.inputMatrix = Matrix.zerosWithRows(3, columns: 3)
        self.lastOperator = ".*"
        updateInputElements()
    }
    
    @IBAction func invDidPress() {
        self.view.endEditing(false)
        if let inv = self.inputMatrix.inverse {
            self.outputMatrix = inv
            updateOutputElements()
        } else {
            let seq = self.outputElements.enumerated()
            for (_, tf) in seq {
                tf.text = ""
            }
            self.outputElements[4].text = "N/A"
        }
        self.lastOperator = ""
    }
    
    @IBAction func didPressEqual() {
        self.view.endEditing(false)
        switch self.lastOperator {
        case "+":
            self.outputMatrix = self.inputMatrix + self.inputMatrix2
            updateOutputElements()
        case "-":
            self.outputMatrix = self.inputMatrix2 - self.inputMatrix
            updateOutputElements()
        case "*":
            self.outputMatrix = self.inputMatrix2 * self.inputMatrix
            updateOutputElements()
        case ".*":
            self.outputMatrix = self.inputMatrix2 *~ self.inputMatrix
            updateOutputElements()
        default: break
            
        }
    }
    
}

