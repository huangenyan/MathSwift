//
//  MathSwiftTests.swift
//  MathSwiftTests
//
//  Created by Enyan Huang on 10/10/14.
//  Copyright (c) 2014 The Hong Kong Polytechnic University. All rights reserved.
//

import UIKit
import XCTest
import MathSwift

class MathSwiftTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMatrixInitByDimension() {
        let m = Matrix(rows: 1, columns: 2)
        XCTAssert(m.rows == 1, "Rows wrong")
        XCTAssert(m.columns == 2, "Columns wrong")
        for e in m {
            XCTAssert(e.isZero, "Initial value of each element should be 0")
        }
    }
    
    func testMatrixInitByElements() {
        let m = Matrix(elements: [[1,2,3],[4,5,6]])
        XCTAssert(m.rows == 2, "Rows wrong")
        XCTAssert(m.columns == 3, "Columns wrong")
    }
    
    func testSubscriptRead() {
        let m = Matrix(elements: [[1,2,3],[4,5,6],[7,8,9]])
        XCTAssert(m[0,0].toDouble() == 1, "First element should be 1")
        XCTAssert(m[[0,1],[0,1]] == Matrix(elements: [[1,2],[4,5]]), "Upper left 2x2 wrong")
        XCTAssert(m[0,[0,1]] == Matrix(elements: [[1,2]]), "Upper left 1x2 wrong")
        XCTAssert(m[[0,1],0] == Matrix(elements: [[1],[4]]), "Upper left 2x1 wrong")
    }
    
    func testSubscriptWrite() {
        var m1 = Matrix(elements: [[1,2,3],[4,5,6],[7,8,9]])
        var m2 = m1, m3 = m1, m4 = m1
        m1[0,0] = 10
        XCTAssert(m1 == Matrix(elements: [[10,2,3],[4,5,6],[7,8,9]]), "First element wrong")
        m2[[0,1],[0,1]] = Matrix(elements: [[10,20],[40,50]])
        XCTAssert(m2 == Matrix(elements: [[10,20,3],[40,50,6],[7,8,9]]), "Upper left 2x2 wrong")
        m3[0,[0,1]] = Matrix(elements: [[10,20]])
        XCTAssert(m3 == Matrix(elements: [[10,20,3],[4,5,6],[7,8,9]]), "Upper left 1x2 wrong")
        m4[[0,1],0] = Matrix(elements: [[10],[40]])
        XCTAssert(m4 == Matrix(elements: [[10,2,3],[40,5,6],[7,8,9]]), "Upper left 2x1 wrong")
    }
    
    func testSubscriptRange() {
        let m = Matrix(elements: [[1,2,3],[4,5,6],[7,8,9]])
        XCTAssert(m[0...1,0...1] == Matrix(elements: [[1,2],[4,5]]), "Upper left 2x2 wrong")
    }
    
    func testSubscriptEmpty() {
        let m = Matrix(elements: [[1,2,3],[4,5,6],[7,8,9]])
        XCTAssert(m[ALL,[0,1]] == Matrix(elements: [[1,2],[4,5],[7,8]]), "Left 2 columns wrong")
    }
    
    func testMatrixPlus() {
        let m1 = Matrix(elements: [[1,2,3],[4,5,6],[7,8,9]])
        let m2 = Matrix(elements: [[1,2,3],[4,5,6],[7,8,9]])
        let m3 = Matrix(elements: [[2,4,6],[8,10,12],[14,16,18]])
        XCTAssert(m1 + m2 == m3, "Plus result wrong")
    }
    
    func testMatrixMinus() {
        let m1 = Matrix(elements: [[1,2,3],[4,5,6],[7,8,9]])
        let m2 = Matrix(elements: [[1,2,3],[4,5,6],[7,8,9]])
        let m3 = Matrix(elements: [[0,0,0],[0,0,0],[0,0,0]])
        XCTAssert(m1 - m2 == m3, "Minus result wrong")
    }
    
    func testMatrixElementwiseMultiply() {
        let m1 = Matrix(elements: [[1,2,3],[4,5,6],[7,8,9]])
        let m2 = Matrix(elements: [[1,2,3],[4,5,6],[7,8,9]])
        let m3 = Matrix(elements: [[1,4,9],[16,25,36],[49,64,81]])
        XCTAssert(m1 *~ m2 == m3, "Multiply result wrong")
    }
    
    func testMatrixElementwiseDevide() {
        let m1 = Matrix(elements: [[1,2,3],[4,5,6],[7,8,9]])
        let m2 = Matrix(elements: [[1,2,3],[4,5,6],[7,8,9]])
        let m3 = Matrix(elements: [[1,1,1],[1,1,1],[1,1,1]])
        XCTAssert(m1 /~ m2 == m3, "Devide result wrong")
    }
    
    func testMatrixElementwiseExp() {
        let m1 = Matrix(elements: [[1,2,3],[4,5,6],[7,8,9]])
        let m2 = Matrix(elements: [[1,4,9],[16,25,36],[49,64,81]])
        XCTAssert(m1 ^~ 2 == m2, "Exp result wrong")
    }
    
    func testTanspose() {
        let m1 = Matrix(elements: [[1,2,3],[4,5,6],[7,8,9]])
        let m2 = Matrix(elements: [[1,4,7],[2,5,8],[3,6,9]])
        XCTAssert(m1.transpose == m2, "Transpose wrong")
    }
    
    func testDotProduct() {
        let m1 = Matrix(elements: [[1],[2],[3],[4],[5]])
        let m2 = Matrix(elements: [[10],[20],[30],[40],[50]])
        let result = 550.0
        XCTAssert(m1.dot(m2) == result, "Dot product wrong")
    }
    
    func testMatrixProduct() {
        let m1 = Matrix(elements: [[1,2,3],[4,5,6]])
        let m2 = Matrix(elements: [[10,20],[30,40],[50,60]])
        let m3 = Matrix(elements: [[220,280],[490,640]])
        XCTAssert(m1 * m2 == m3, "Matrix product wrong")
    }
    
    func testZeros() {
        let m1 = Matrix.zerosWithRows(2, columns: 3)
        let m2 = Matrix(elements: [[0,0,0],[0,0,0]])
        XCTAssert(m1 == m2, "Zeros wrong")
    }
    
    func testOnes() {
        let m1 = Matrix.onesWithRows(2, columns: 3)
        let m2 = Matrix(elements: [[1,1,1],[1,1,1]])
        XCTAssert(m1 == m2, "Ones wrong")
    }
    
    func testIdentity() {
        let m1 = Matrix.identityWithSize(3)
        let m2 = Matrix(elements: [[1,0,0],[0,1,0],[0,0,1]])
        XCTAssert(m1 == m2, "Identity wrong")
    }
    
    func testDiagonal() {
        let m1 = Matrix(elements: [[1,2,3],[4,5,6],[7,8,9]])
        let m1Diag = Matrix(elements: [[1,0,0],[0,5,0],[0,0,9]])
        XCTAssert(m1.diagonal == m1Diag, "Diagonal wrong for square matrix")
        
        let m2 = Matrix(elements: [[1,2,3],[4,5,6]])
        let m2Diag = Matrix(elements: [[1,0,0],[0,5,0]])
        XCTAssert(m2.diagonal == m2Diag, "Diagonal wrong for rectangle matrix (m < n)")
        
        let m3 = Matrix(elements: [[1,2],[3,4],[5,6]])
        let m3Diag = Matrix(elements: [[1,0],[0,4],[0,0]])
        XCTAssert(m3.diagonal == m3Diag, "Diagonal wrong for rectangle matrix (m > n)")
        
    }
    
    func testDeterminant() {
            let m1 = Matrix(elements: [[1,2,3],[4,5,6],[7,8,9]])
            XCTAssert(doublePrecisionEqual(m1.determinant, 0), "Determinant wrong for singular matrix")
            let m2 = Matrix(elements: [[1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,1]])
            XCTAssert(m2.determinant == 1, "Determinant wrong for I(4x4)")
            let m3 = Matrix.identityWithSize(5)
            XCTAssert(m3.determinant == 1, "Determinant wrong for I(5x5)")
            let m4 = Matrix(elements: [[1,2,0],[-1,1,1],[1,2,3]])
            XCTAssert(m4.determinant == 9, "Determinant wrong for a 3x3 matrix")
    }
    
    func testInverse() {
        self.measure() {
            let m1 = Matrix.identityWithSize(5)
            XCTAssert(m1.inverse == m1, "Inverse wrong for I(5x5)")
            let m2 = Matrix(elements: [[1,2,3],[3,2,1],[2,1,3]])
            let m2Inv = Matrix(elements: [[-5,3,4],[7,3,-8],[1,-3,4]]) / 12
            XCTAssert(m2.inverse == m2Inv, "Inverse wrong for a 3x3 matrix")
        }
    }
    
    func testReshape() {
        let m1 = Matrix(elements: [[1,2,3],[4,5,6]])
        let m1Reshape3x2 = Matrix(elements: [[1,2],[3,4],[5,6]])
        let m1Reshape1x6 = Matrix(elements: [[1,2,3,4,5,6]])
        let m1Reshape6x1 = Matrix(elements: [[1],[2],[3],[4],[5],[6]])
        XCTAssert(m1.reshapeToRows(3, columns: 2) == m1Reshape3x2, "Reshape 2x3 to 3x2 wrong")
        XCTAssert(m1.reshapeToRows(1, columns: 6) == m1Reshape1x6, "Reshape 2x3 to 1x6 wrong")
        XCTAssert(m1.reshapeToRows(6, columns: 1) == m1Reshape6x1, "Reshape 2x3 to 6x1 wrong")
    }
    
    func testMatrixConcatenate() {
        let m1 = Matrix(elements: [[11,12],[21,22],[31,32]])
        let m2 = Matrix(elements: [[13],[23],[33]])
        let m3 = Matrix(elements: [[41,42,43]])
        let result = Matrix(elements: [[11,12,13],[21,22,23],[31,32,33],[41,42,43]])
        XCTAssert(m1 +++ m2 --- m3 == result, "Concatenate wrong")
    }
    
    func testReduction() {
        let m1 = Matrix(elements: [[1,2,3],[4,5,6]])
        let m1Result1 = Matrix(elements: [[5,7,9]])
        let m1Result2 = Matrix(elements: [[6],[15]])
        XCTAssert(m1.reduceAlongDimension(.column, initial: 0, combine: +) == m1Result1, "Reduce along columns wrong")
        XCTAssert(m1.reduceAlongDimension(.row, initial: 0, combine: +) == m1Result2, "Reduce along rows wrong")
    }
    
    func testFormat() {
        let constant = sqrt(2.0)
        let m1 = Matrix(elements: [[constant,0,2.3],[1,constant/2,1.87432],[0,2.5,0]])
        print(m1)
    }
    
    func testSVD() {
        let m = Matrix(elements: [[1,2,3],[4,5,6],[7,8,9]])
        let (U,S,VT) = m.singularValueDecomposition()
        XCTAssert(U * U.transpose == Matrix.identityWithSize(m.rows), "U should be orthogonal")
        XCTAssert(VT * VT.transpose == Matrix.identityWithSize(m.columns), "V should be orthogonal")
        XCTAssert(m == U * S * VT, "M should be equal to U*S*VT")
    }
    
    func testEigen() {
        let m = Matrix(elements: [[1,2],[3,4]])
        let (values, vectors) = m.eigen()
        XCTAssert(m * vectors[0] == values[0] * vectors[0], "Eigen wrong")
        XCTAssert(m * vectors[1] == values[1] * vectors[1], "Eigen wrong")
    }

}
