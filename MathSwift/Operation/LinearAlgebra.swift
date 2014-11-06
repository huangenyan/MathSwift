//
//  LinearAlgebra.swift
//  MathSwift
//
//  Created by Enyan HUANG on 6/11/14.
//  Copyright (c) 2014 The Hong Kong Polytechnic University. All rights reserved.
//

import Foundation

extension Matrix {
//    public func singularValueDecomposition() -> (U: Matrix, L: Matrix, VTranspose: Matrix) {
//        
//    }
//    
//    public func eigen() -> (eigenvector: Matrix, eigenvalue: Double) {
//        
//    }
    
    /// Return the QR-decomposition of `self`.
    public func QRDecomposition() -> (Q: Matrix, R: Matrix) {
        assert(self.rows >= self.columns, "Rows must be not fewer than columns for QR decomposition")
        var Q = Matrix(rows: self.rows, columns: self.columns)
        Q[ALL,0] = self[ALL,0]
        for i in 1..<self.columns {
            Q[ALL,i] = self[ALL,i]
            for j in 0..<i {
                Q[ALL,i] = Q[ALL,i] - self[ALL,i].projectionOnVector(Q[ALL,j])
                
            }
        }
        
        for i in 0..<Q.columns {
            var length = 0.0
            for j in 0..<Q.rows {
                length += Q[j,i].toDouble()! ^ 2
            }
            length = sqrt(length)
            Q[ALL,i] = Q[ALL,i] / length
        }
        
        let R = Q.transpose * self
        return (Q, R)
        
    }


}