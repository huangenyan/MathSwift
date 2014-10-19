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
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testMatrixInit() {

        let m = Matrix(rows: 1, columns: 2)
        XCTAssert(m.numRows == 1, "Rows wrong")
        XCTAssert(m.numColumns == 2, "Colmns wrong")
    }
}
