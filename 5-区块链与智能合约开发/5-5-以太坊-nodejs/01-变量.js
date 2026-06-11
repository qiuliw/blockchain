
//1. var允许对同一个变量重新定义，把原有变量值改变
var a = 10
var a = 'hello'

console.log('a:', a)

//2. let 允许修改，但不允许重新定义
let b = 100
console.log('b:', b)

//SyntaxError: Identifier 'b' has already been declared
// let b= 1000

b = 'helloworld'
console.log('b:', b)

//3. const 不允许修改

const c = 50
console.log('c:', c)

// c= 60
