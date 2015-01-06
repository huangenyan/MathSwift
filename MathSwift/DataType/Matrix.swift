//
//  MSMatrix.swift
//  MathSwift
//
//  Created by Enyan Huang on 10/10/14.
//  Copyright (c) 2014 The Hong Kong Polytechnic University. All rights reserved.
//

import Foundation
import Accelerate

public enum MatrixDimension {
    case Row, Column
}

public protocol MatrixIndexType {}

extension Array: MatrixIndexType {}
extension Range: MatrixIndexType {}
extension Int: MatrixIndexType {}

func toIntArray(index: MatrixIndexType) -> [Int] {
    
    if let intArrayIndex = index as? [Int] {
        return index as [Int]
    } else if let rangeIndex = index as? Range<Int> {
        return rangeIndex.map({$0})
    } else if let intIndex = index as? Int {
        return [intIndex]
    }
    return []
}

/// `ALL` is used to represent all rows or all columns
public let ALL = [Int]()

public struct Matrix {
    
    public let rows: Int, columns: Int
    
    var elements: [Double]
    
    public var size: (Int, Int) {
        return (rows, columns)
    }
    
    /// Return the transpose matrix of `self`
    public var transpose: Matrix {
        var result = Matrix(rows: self.columns, columns: self.rows)
        vDSP_mtransD(self.elements, 1, &result.elements, 1, vDSP_Length(self.rows), vDSP_Length(self.columns))
        return result
    }
    
    /// Return the diagonal matrix of `self`
    public var diagonal: Matrix {
        var result = Matrix(rows: self.rows, columns: self.columns)
        
        if self.rows < self.columns {
            for i in 0..<self.rows {
                result[i,i] = self[i,i]
            }
        } else {
            for i in 0..<self.columns {
                result[i,i] = self[i,i]
            }
        }
        
        return result
    }
    
    /// Return the inverse matrix of `self`. If `self` is singular or not a square matrix, return nil.
    public var inverse: Matrix? {
        
        if self.rows != self.columns {
            return nil
        }
        var inMatrix = self.elements
        var N = __CLPK_integer(sqrt(Double(self.elements.count)))
        var pivots = [__CLPK_integer](count: Int(N), repeatedValue: 0)
        var workspace = [Double](count: Int(N), repeatedValue: 0.0)
        var error : __CLPK_integer = 0
        dgetrf_(&N, &N, &inMatrix, &N, &pivots, &error)
        
        if error != 0 {
            return nil
        }
        
        dgetri_(&N, &inMatrix, &N, &pivots, &workspace, &N, &error)
        var result = Matrix(rows: self.rows, columns: self.columns)
        result.elements = inMatrix
        return result
    }
    
    /// Return the determinant of `self`, where `self` must be a square matrix.
    public var determinant: Double {
        assert(self.rows == self.columns, "Determinant can only computed on square matrix")
        
        var m = __CLPK_integer(self.rows)
        var n = __CLPK_integer(self.columns)
        var a = self.transpose.elements
        var lda = m
        var ipiv = [__CLPK_integer](count: min(self.rows, self.columns), repeatedValue: 0)
        var info: __CLPK_integer = 0
        dgetrf_(&m, &n, &a, &lda, &ipiv, &info)
        
        let luMatrix = Matrix(rows: self.rows, columns: self.columns, elements: a)
        var result = 1.0
        for i in 0..<min(self.rows, self.columns) {
            result *= luMatrix[i,i].toDouble()!
        }
        
        var noi = 0
        for i in 0..<min(self.rows, self.columns) {
            if i != Int(ipiv[i]) {
                noi++
            }
        }
        if noi % 2 == 1 {
            result *= -1
        }
        if min(self.rows, self.columns) % 2 == 1 {
            result *= -1
        }
        return result

    }

    /// Create a matrix using a tuple with (`rows`, `columns`), and `elements` are initialzed to 0.
    public init(size: (rows: Int, columns: Int)) {
        self.rows = size.rows
        self.columns = size.columns
        elements = Array(count: rows * columns, repeatedValue: 0.0)
    }
    
    /// Create a matrix using the `rows` and `columns`, and `elements` are initialzed to 0.
    public init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
        self.elements = Array(count: rows * columns, repeatedValue: 0.0)
    }
    
    /// Create a matrix using a 2D-array with the form [[row1],[row2]...], the size of the matrix is inferred from the 2D-array.
    public init(elements: [[Double]]) {
        self.elements = [Double]()
        for row in elements {
            assert(row.count == elements[0].count, "Length of each row must be equal")
            self.elements += row
        }
        self.rows = elements.count
        self.columns = elements[0].count
    }
    
    /// Create a matrix using the `rows`, `columns` and `elements`.
    public init(rows: Int, columns: Int, elements: [Double]) {
        self.rows = rows
        self.columns = columns
        self.elements = elements
    }
    
    /// Create a `rows` by `columns` matrix filling with 0s.
    public static func zerosWithRows(rows: Int, columns: Int) -> Matrix {
        return Matrix(rows: rows, columns: columns)
    }
    
    /// Create a `rows` by `columns` matrix filling with 1s.
    public static func onesWithRows(rows: Int, columns: Int) -> Matrix {
        var result = Matrix(rows: rows, columns: columns)
        result.elements = Array(count: rows * columns, repeatedValue: 1.0)
        return result
    }
    
    /// Create a `size` by `size` identity matrix.
    public static func identityWithSize(size: Int) -> Matrix {
        var result = Matrix(rows: size, columns: size)
        for i in 0..<size {
            result[i,i] = 1.0
        }
        return result
    }
    
    /// M[[0,2],[0,1,2]] = [a00 a01 a02; a20 a21 a22]
    public subscript(rows: MatrixIndexType, columns: MatrixIndexType) -> Matrix {
        get {
            let rowArray = toIntArray(rows)
            let columnArray = toIntArray(columns)
            var realRows = rowArray, realColumns = columnArray
            if rowArray.isEmpty {
                realRows = (0..<self.rows).map({$0})
            }
            if columnArray.isEmpty {
                realColumns = (0..<self.columns).map({$0})
            }
            
            var M = Matrix(rows: realRows.count, columns: realColumns.count)
            for i in 0..<realRows.count {
                for j in 0..<realColumns.count {
                    assert(realRows[i] < self.rows && realColumns[j] < self.columns, "Index out of bound: try to access index [\(realRows[i]),\(realColumns[i])] for a \(self.rows)x\(self.columns) matrix")
                    M.elements[(i * M.columns) + j] = elements[realRows[i] * self.columns + realColumns[j]]
                }
            }
            return M
        }
        set {
            let rowArray = toIntArray(rows)
            let columnArray = toIntArray(columns)
            var realRows = rowArray, realColumns = columnArray
            if rowArray.isEmpty {
                realRows = (0..<self.rows).map({$0})
            }
            if columnArray.isEmpty {
                realColumns = (0..<self.columns).map({$0})
            }
            for i in 0..<realRows.count {
                for j in 0..<realColumns.count {
                    elements[(realRows[i] * self.columns) + realColumns[j]] = newValue.elements[(i * newValue.columns) + j]
                }
            }
        }
    }
    
    /// Convert a 1x1 matrix to its double value. If the matrix is not 1x1, return nil.
    public func toDouble() -> Double? {
        if self.columns == 1 && self.rows == 1 {
            return self.elements[0]
        } else {
            return nil
        }
    }

    /// Reduce the matrix to a single row or a single column. E.g. "M.reduceAlongDimensiion(.row, initial: 0, combine: +)" will sum each row to produce a vector.
    public func reduceAlongDimension(dimension: MatrixDimension, initial: Double, combine: (Double, Double) -> Double) -> Matrix {
        var result: Matrix
        switch dimension {
        case .Row:
            result = Matrix.onesWithRows(self.rows, columns: 1) * initial
            for i in 0..<self.rows {
                for j in 0..<self.columns {
                    result[i,0] = combine(result[i,0].toDouble()!, self[i,j].toDouble()!).toMatrix()
                }
            }
        case .Column:
            result = Matrix.onesWithRows(1, columns: self.columns) * initial
            for i in 0..<self.columns {
                for j in 0..<self.rows {
                    result[0,i] = combine(result[0,i].toDouble()!, self[j,i].toDouble()!).toMatrix()
                }
            }

        }
        return result
    }
    
    /// Return the projection vector of `self` on `v`, where `self` and `v` must be both vectors.
    public func projectionOnVector(v: Matrix) -> Matrix {
        assert(self.columns == v.columns && self.columns == 1, "Only vectors can be projected")
        assert(self.rows == v.rows, "Two vectors should have the same length")
        return self.dot(v) / v.dot(v) * v
    }
    
    /// Return the dot product of `self` and `m`.
    public func dot(m: Matrix) -> Double {
        assert(self.columns == 1 && m.columns == 1, "Dot product can only be performed on vectors")
        assert(self.rows == m.rows, "Length mismatch for two vectors")
        var selfCopy = self
        var mCopy = m
        var result = 0.0
        vDSP_dotprD(&selfCopy.elements, 1, &mCopy.elements, 1, &result, vDSP_Length(self.rows))
        
        return result
    }
    
    /// Reshape `self` to a `rows` by `columns` matrix.
    public func reshapeToRows(rows: Int, columns: Int) -> Matrix {
        assert(self.rows * self.columns == rows * columns, "Reshaped matrix must contain the same number of elements")
        var result = Matrix(rows: rows, columns: columns)
        result.elements = self.elements
        return result
    }

}

extension Matrix: Equatable {}

extension Matrix: Printable {
    public var description: String {
        var result = ""
        for i in 0..<self.rows {
            for j in 0..<self.columns {
                result += NSString(format: "%.3f\t", self[i,j].toDouble()!)
            }
            result += "\n"
        }
        return result
    }
}

extension Matrix: SequenceType {
    
    public func generate() -> GeneratorOf<Double> {
        var nextIndex = 0
        return GeneratorOf<Double> {
            if nextIndex == self.elements.count {
                return nil
            }
            return self.elements[nextIndex++]
        }
    }
}

extension Matrix: IntegerLiteralConvertible {
    
    /// Create a 1x1 matrix by literal.
    public init(integerLiteral value: IntegerLiteralType) {
        self.rows = 1
        self.columns = 1
        self.elements = [Double(value)]
    }
}

extension Matrix: FloatLiteralConvertible {
    
    /// Create a 1x1 matrix by literal.
    public init(floatLiteral value: FloatLiteralType) {
        self.rows = 1
        self.columns = 1
        self.elements = [value]
    }
}

public func == (lhs: Matrix, rhs: Matrix) -> Bool {
    if lhs.columns == rhs.columns && lhs.rows == rhs.rows {
        for i in 0..<lhs.elements.count {
            if !doublePrecisionEqual(lhs.elements[i], rhs.elements[i]) {
                break;
            } else if i == lhs.elements.count - 1 {
                return true
            }
        }
    }
    
    return false
}

public func doublePrecisionEqual(a: Double, b: Double) -> Bool {
    let epsilon = 1e-14
    if a >= b - epsilon && a <= b + epsilon {
        return true
    }
    return false
}

public func != (lhs: Matrix, rhs: Matrix) -> Bool {
    return !(lhs == rhs)
}

infix operator *~ {associativity left precedence 150}
infix operator /~ {associativity left precedence 150}
infix operator ^~ {associativity right precedence 155}
infix operator ^  {associativity right precedence 155}
infix operator +++ {associativity left precedence 138}
infix operator --- {associativity left precedence 138}

/// 2 ^ 3 = 8
public func ^ (lhs: Double, rhs: Double) -> Double {
    return pow(lhs, rhs)
}

/// [1 2; 3 4] + [1 1; 1 1] = [2 3; 4 5]
public func + (lhs: Matrix, rhs: Matrix) -> Matrix {
    assert(lhs.columns == rhs.columns && lhs.rows == rhs.rows, "Two matrices must have the same dimension")
    var lhsCopy = lhs
    var rhsCopy = rhs
    var result = Matrix(size: lhs.size)
    vDSP_vaddD(&lhsCopy.elements, 1, &rhsCopy.elements, 1, &result.elements, 1, vDSP_Length(lhs.elements.count))
    return result
}

/// [1 2; 3 4] - [1 1; 1 1] = [0 1; 2 3]
public func - (lhs: Matrix, rhs: Matrix) -> Matrix {
    assert(lhs.columns == rhs.columns && lhs.rows == rhs.rows, "Two matrices must have the same dimension")
    var lhsCopy = lhs
    var rhsCopy = rhs
    var result = Matrix(size: lhs.size)
    vDSP_vsubD(&lhsCopy.elements, 1, &rhsCopy.elements, 1, &result.elements, 1, vDSP_Length(lhs.elements.count))
    return result
}

/// [1 2; 3 4] + 1 = [2 3; 4 5]
public func + (lhs: Matrix, rhs: Double) -> Matrix {
    var lhsCopy = lhs
    var rhsCopy = rhs
    var result = Matrix(size: lhs.size)
    vDSP_vsaddD(&lhsCopy.elements, 1, &rhsCopy, &result.elements, 1, vDSP_Length(lhs.elements.count))
    return result
}

/// 1 + [1 2; 3 4] = [2 3; 4 5]
public func + (lhs: Double, rhs: Matrix) -> Matrix {
    var lhsCopy = lhs
    var rhsCopy = rhs
    var result = Matrix(size: rhs.size)
    vDSP_vsaddD(&rhsCopy.elements, 1, &lhsCopy, &result.elements, 1, vDSP_Length(rhs.elements.count))
    return result
}

/// [1 2; 3 4] - 1 = [0 1; 2 3]
public func - (lhs: Matrix, rhs: Double) -> Matrix {
    var lhsCopy = lhs
    var result = Matrix(size: lhs.size)
    var negRhs = -rhs
    vDSP_vsaddD(&lhsCopy.elements, 1, &negRhs, &result.elements, 1, vDSP_Length(lhs.elements.count))
    return result
}

/// -[1 2; 3 4] = [-1 -2; -3 -4]
public prefix func - (matrix: Matrix) -> Matrix {
    var matrixCopy = matrix
    var result = Matrix(size: matrix.size)
    vDSP_vnegD(&matrixCopy.elements, 1, &result.elements, 1, vDSP_Length(matrix.elements.count))
    return result
}

/// 1 - [1 2; 3 4] = [0 -1; -2 -3]
public func - (lhs: Double, rhs: Matrix) -> Matrix {
    return lhs + (-rhs)
}

/// [1 2; 3 4] *~ [2 2; 2 2] = [2 4; 6 8]
public func *~ (lhs: Matrix, rhs: Matrix) -> Matrix {
    assert(lhs.columns == rhs.columns && lhs.rows == rhs.rows, "Two matrices must have the same dimension")
    var lhsCopy = lhs
    var rhsCopy = rhs
    var result = Matrix(size: lhs.size)
    vDSP_vmulD(&lhsCopy.elements, 1, &rhsCopy.elements, 1, &result.elements, 1, vDSP_Length(lhs.elements.count))
    return result
}

/// [2 4; 6 8] /~ [2 2; 2 2] = [2 4; 6 8]
public func /~ (lhs: Matrix, rhs: Matrix) -> Matrix {
    assert(lhs.columns == rhs.columns && lhs.rows == rhs.rows, "Two matrices must have the same dimension")
    var lhsCopy = lhs
    var rhsCopy = rhs
    var result = Matrix(size: lhs.size)
    vDSP_vdivD(&lhsCopy.elements, 1, &rhsCopy.elements, 1, &result.elements, 1, vDSP_Length(lhs.elements.count))
    return result
}

/// [1 2; 3 4] * 2 = [2 4; 6 8]
public func * (lhs: Matrix, rhs: Double) -> Matrix {
    var lhsCopy = lhs
    var rhsCopy = rhs
    var result = Matrix(size: lhs.size)
    var zero = 0.0
    vDSP_vsmsaD(&lhsCopy.elements, 1, &rhsCopy, &zero, &result.elements, 1, vDSP_Length(lhs.elements.count))
    return result
}

/// 2 * [1 2; 3 4] = [2 4; 6 8]
public func * (lhs: Double, rhs: Matrix) -> Matrix {
    var lhsCopy = lhs
    var rhsCopy = rhs
    var result = Matrix(size: rhs.size)
    var zero = 0.0
    vDSP_vsmsaD(&rhsCopy.elements, 1, &lhsCopy, &zero, &result.elements, 1, vDSP_Length(rhs.elements.count))
    return result
}

/// [2 4; 6 8] / 2 = [1 2; 3 4]
public func / (lhs: Matrix, rhs: Double) -> Matrix {
    var lhsCopy = lhs
    var rhsCopy = rhs
    var result = Matrix(size: lhs.size)
    vDSP_vsdivD(&lhsCopy.elements, 1, &rhsCopy, &result.elements, 1, vDSP_Length(lhs.elements.count))
    return result
}

/// 12 / [1 2; 3 4] = [12 6; 4 3]
public func / (lhs: Double, rhs: Matrix) -> Matrix {
    var lhsCopy = lhs
    var rhsCopy = rhs
    var result = Matrix(size: rhs.size)
    vDSP_svdivD(&rhsCopy.elements, &lhsCopy, 1, &result.elements, 1, vDSP_Length(rhs.elements.count))
    return result
}

/// [1 2; 3 4] ^~ 2 = [1 4; 9 16]
public func ^~ (lhs: Matrix, rhs: Double) -> Matrix {
    var result = Matrix(rows: lhs.rows, columns: lhs.columns)
    for i in 0..<lhs.elements.count {
        result.elements[i] = lhs.elements[i] ^ rhs
    }
    return result
}

/// [1 2; 3 4] ^ 2 = [1 2; 3 4] * [1 2; 3 4] = [7 10; 15 22]
public func ^ (lhs: Matrix, rhs: Int) -> Matrix {
    assert(lhs.rows == lhs.columns, "Matrix exponentiation can only be performed on square matrix")
    if rhs < 0 {
        assert(lhs.determinant != 0, "Invalid exponentiation opertion beacase the matrix is singular.")
        return (lhs ^ (-rhs)).inverse!
    } else if rhs == 0 {
        return Matrix.identityWithSize(lhs.rows)
    } else {
        return lhs * (lhs ^ (rhs - 1))
    }
}

/// Production of two matrices.
public func * (lhs: Matrix, rhs: Matrix) -> Matrix {
    assert(lhs.columns == rhs.rows, "Dimension mismatch of multiplied matrices")
    var lhsCopy = lhs
    var rhsCopy = rhs
    var result = Matrix(rows: lhs.rows, columns: rhs.columns)
    vDSP_mmulD(&lhsCopy.elements, 1, &rhsCopy.elements, 1, &result.elements, 1, vDSP_Length(result.rows), vDSP_Length(result.columns), vDSP_Length(lhs.columns))
    return result
}

/// Horizontal concantenation of two matrices. [1 2; 3 4] +++ [5; 6] = [1 2 5; 3 4 6]
public func +++ (lhs: Matrix, rhs: Matrix) -> Matrix {
    assert(lhs.rows == rhs.rows, "Matrices must have the same number of rows for horizontal concatenation")
    var result = Matrix(rows: lhs.rows, columns: lhs.columns + rhs.columns)
    for i in 0..<result.columns {
        if i < lhs.columns {
            result[ALL,i] = lhs[ALL,i]
        } else {
            result[ALL,i] = rhs[ALL,i-lhs.columns]
        }
    }
    return result
}

/// Vertical concantenation of two matrices. [1 2; 3 4] --- [5 6] = [1 2; 3 4; 5 6]
public func --- (lhs: Matrix, rhs: Matrix) -> Matrix {
    assert(lhs.columns == rhs.columns, "Matrices must have the same number of rows for vertical concatenation")
    var result = Matrix(rows: lhs.rows + rhs.rows, columns: lhs.columns)
    for i in 0..<result.rows {
        if i < lhs.rows {
            result[i,ALL] = lhs[i,ALL]
        } else {
            result[i,ALL] = rhs[i-lhs.rows,ALL]
        }
    }
    return result
}

extension Double {
    
    /// Convert a double to a 1x1 matrix
    public func toMatrix() -> Matrix {
        return Matrix(elements: [[self]])
    }
}
