//
//  MSMatrix.swift
//  MathSwift
//
//  Created by Enyan Huang on 10/10/14.
//  Copyright (c) 2014 The Hong Kong Polytechnic University. All rights reserved.
//

public struct Matrix {
    
    public let rows: Int, columns: Int
    public var elements: [Double]
    
    
    public init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
        elements = Array(count: rows * columns, repeatedValue: 0.0)
    }
    public init(elements: [[Double]]) {
        self.elements = Array()
        for row in elements {
            assert(row.count == elements[0].count, "Length of each row must be equal")
            self.elements += row
        }
        self.rows = elements.count
        self.columns = elements[0].count
    }
    
    public subscript(row: Int, column: Int) -> Double {
        get {
            return self[[row], [column]];
        }
        set {

        }
    }
    
    public subscript(rows: [Int], columns: [Int]) -> Matrix {
        get {
            var M = Matrix(rows: rows.count, columns: columns.count)
            for i in 0..<rows.count {
                for j in 0..<columns.count {
                    M.elements[(i * M.columns) + j] = elements[rows[i] * self.columns + columns[j]]
                }
            }
            return M
        }
        set {
            for i in 0..<rows.count {
                for j in 0..<columns.count {
                    elements[(rows[i] * self.columns) + columns[j]] = newValue.elements[(i * newValue.columns) + j]
                }
            }
        }
    }
    
    func isValidIndexOfRow(row: Int, column: Int) -> Bool {
        return abs(row) < self.rows && abs(column) < self.columns
    }
    
    
}