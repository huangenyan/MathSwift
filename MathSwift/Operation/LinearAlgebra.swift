//
//  LinearAlgebra.swift
//  MathSwift
//
//  Created by Enyan HUANG on 6/11/14.
//  Copyright (c) 2014 The Hong Kong Polytechnic University. All rights reserved.
//

import Foundation
import Accelerate

extension Matrix {
    
    public func eigen() -> (eigenvalues: [Double], eigenvectors: [Matrix]) {
        assert(self.rows == self.columns, "Square matrix is required to compute eigen values")
        var jobvl: Int8 = 78
        var jobvr: Int8 = 86
        var n = __CLPK_integer(self.rows)
        var a = self.transpose.elements
        var lda = n
        var wr = [Double](repeating: 0.0, count: self.rows)
        var wi = [Double](repeating: 0.0, count: self.rows)
        var vl = [Double](repeating: 0.0, count: self.rows * self.rows)
        var ldvl = n
        var vr = [Double](repeating: 0.0, count: self.rows * self.rows)
        var ldvr = n
        var lwork = n * 4
        var work = [Double](repeating: 0.0, count: Int(lwork))
        var info: __CLPK_integer = 0
        
        dgeev_(&jobvl, &jobvr, &n, &a, &lda, &wr, &wi, &vl, &ldvl, &vr, &ldvr, &work, &lwork, &info)
        
        var eigenvectors = [Matrix](repeating: Matrix(rows: self.rows, columns: 1), count: self.rows)
        for i in 0..<self.rows {
            for j in 0..<self.rows {
                eigenvectors[i].elements[j] = vr[i * self.rows + j]
            }
            
        }
        
        return (wr, eigenvectors)
    }
    
    public func singularValueDecomposition() -> (U: Matrix, S: Matrix, VT: Matrix) {
        
        var jobz: Int8 = Int8(UnicodeScalar("A").value)
        var m = __CLPK_integer(self.rows)
        var n = __CLPK_integer(self.columns)
        let minMN = m < n ? m : n
        let maxMN = m < n ? n : m
        var a = self.transpose.elements
        var lda = m
        var ldu = m
        var ldvt = n
        var lwork = __CLPK_integer(Int(minMN)*(6+4*Int(minMN))+Int(maxMN))
        var iwork = [__CLPK_integer](repeating: 0, count: 8*Int(minMN))
        var info: __CLPK_integer = 0
        var work = [Double](repeating: 0.0, count: Int(lwork))
        var u = [Double](repeating: 0.0, count: self.rows * self.rows)
        var s = [Double](repeating: 0.0, count: Int(minMN))
        var vt = [Double](repeating: 0.0, count: self.columns * self.columns)
        
        dgesdd_(&jobz, &m, &n, &a, &lda, &s, &u, &ldu, &vt, &ldvt, &work, &lwork, &iwork, &info)
        
        let U = Matrix(rows: self.rows, columns: self.rows, elements: u)
        var S = Matrix(rows: self.rows, columns: self.columns)
        for i in 0..<Int(minMN) {
            S[i,i] = s[i].toMatrix()
        }
        let VT = Matrix(rows: self.columns, columns: self.columns, elements: vt)
        
        return (U.transpose, S, VT.transpose)
    }

}
