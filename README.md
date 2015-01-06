MathSwift
=========
MathSwift is an iOS Dynamic Framework written in Swift which supports complex mathmatical operations. Currently it mainly support matrix and some advanced linear  algrbra operations such as singular value decomposition. It may also serve as a demostration of good practice for developing iOS/OSX dynamic frameworks in pure Swift, including a complete set of unit tests.
# Installation
If you just want to use MathSwift in your own project, you only need to open MathSwift in Xcode, then press cmd+B to build the project. You will find a MathSwift.framework in the "Proucts" group. You can move it to your own project folder and add it into the project like adding other frameworks.

Remember to add `import MathSwift` in the class where you use it. Please notice that MathSwift is written in pure Swift so it **DOESN'T** work with Objective-C code.
# Usage
The full documentation of MathSwift isn't available yet. However, each public method is well commented in the code so you may refer to it. Here I just show some examples.
## Create a matrix
There are several ways for initializing a matrix:
```Swift
// Create with dimension
let m1 = Matrix(rows:3, columns:3)

// Create with 2D-array
let m2 = Matrix(elements:[[11,12,13],[21,22,23],[31,32,33]])
```
## Access elements
You can access the element(s) in the matrix by using the subscript syntax with the format *m[row(s), column(s)]*:
```Swift
var m = Matrix(elements:[[11,12,13],[21,22,23],[31,32,33]])

// Index is an integer. subscript syntax will always return a Matrix so we need to convert it to double manually.
// Get
let a11: Double = m[0,0].toDouble()!
// Set
m[0,0] = a11.toMatrix()
m[0,0] = 0.0 // Double literal will be automatically converted to Matrix

// Index is an array.
// Get
let firstCol = m[[0,1,2],0] // == [[11],[21],[31]]
let firstLastCol = m[[0,1,2],[0,2]] // == [[11,13],[21,23],[31,33]]
// Set
m[[0,1,2],0] = firstCol

// Index is a range.
// Get
let firstTwoCol = m[[0,1,2],0..<2]
let upperLeft4 = m[0...1,0...1]
// Set
m[0...1,0...1] = upperLeft4

// Index is `ALL`
// Get
let firstRow = m[0,ALL] // equals to m[0,[0,1,2]]
// Set
m[0,ALL] = firstRow
```
## Operations on matrix
I hope the code below will explain everything about operators :]. Please note this is not Swift code but just some intuitive expressions, which is similar to the matrix expression in Matlab.
```
// Addition and subtraction
[1 2; 3 4] + [1 1; 1 1] = [2 3; 4 5]
[1 2; 3 4] - [1 1; 1 1] = [0 1; 2 3]
[1 2; 3 4] + 1 = [2 3; 4 5]
1 + [1 2; 3 4] = [2 3; 4 5]
[1 2; 3 4] - 1 = [0 1; 2 3]
-[1 2; 3 4] = [-1 -2; -3 -4]
1 - [1 2; 3 4] = [0 -1; -2 -3]

// Element-wise multiplication/division
[1 2; 3 4] *~ [2 2; 2 2] = [2 4; 6 8]
[2 4; 6 8] /~ [2 2; 2 2] = [2 4; 6 8]

// Scalar multiplication/division
[1 2; 3 4] * 2 = [2 4; 6 8]
2 * [1 2; 3 4] = [2 4; 6 8]
[2 4; 6 8] / 2 = [1 2; 3 4]
12 / [1 2; 3 4] = [12 6; 4 3]

// Element-wise exponentiation
[1 2; 3 4] ^~ 2 = [1 4; 9 16]

// Matrix exponentiation
[1 2; 3 4] ^ 2 = [1 2; 3 4] * [1 2; 3 4] = [7 10; 15 22]

// Production of two matrices
[1 2; 3 4] * [1 2; 3 4] = [7 10; 15 22]

// Horizontal concantenation
[1 2; 3 4] +++ [5; 6] = [1 2 5; 3 4 6]

// Vertical concantenation
[1 2; 3 4] --- [5 6] = [1 2; 3 4; 5 6]

```
The transpose, inverse and some other properties of a matrix is available as well. For example, you can get the transpose of a matrix by `m.transpose`. 
