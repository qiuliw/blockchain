var Web3 = require('Web3')
var web3 = new Web3()

console.log("先将字符串'xyz'转换为ascii，然后转化为十六进制")
var str = web3.utils.fromAscii('xyz')
console.log(str)

console.log("先将十六进制转换为ascii，然后转化为字符串")
str = web3.utils.toAscii('0x78797a')
console.log(str)
