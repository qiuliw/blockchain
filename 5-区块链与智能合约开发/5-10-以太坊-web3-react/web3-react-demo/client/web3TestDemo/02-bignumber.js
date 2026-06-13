const BigNumber = require('bignumber.js') //导出的是构造函数，一般是大写开头，需要使用new实例化
const { Web3 } = require('web3')
const web3 = new Web3()

let v1 = 101010100324325345346456456456456456456
let v2 = 10

//当数据很大时，js数据运算会失去精度
console.log('v1 + v2:', v1 + v2) //v1 + v2: 1.0101010032432535e+38


//需要使用bignumber.js库来处理大数据
let v3 = new BigNumber('101010100324325345346456456456456456456666666666666666')
let v4 = new BigNumber('10')

console.log('v3 + v4：', v3.plus(v4).toString())

// web3 4.x 链上数值使用原生 BigInt
let v5 = BigInt('101010100324325345346456456456456456456666666666666666')
let v6 = BigInt('10')

console.log('v5 + v6 :', (v5 + v6).toString())


let v7 = new BigNumber('-123.45')

//s : 符号， 1， -1
//e : 指数， 10 **2 里面的2
//c : 数值， 1.2345
//1.2345 * 10 **2

console.log('v7:', v7)
console.log('v7:', v7.toString())
