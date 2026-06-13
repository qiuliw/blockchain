const { Web3 } = require('web3')
const web3 = new Web3()

console.log("先将字符串'xyz'转换为ascii，然后转化为十六进制")
var str = web3.utils.utf8ToHex('xyz')
console.log(str)

console.log("先将十六进制转换为ascii，然后转化为字符串")
str = web3.utils.hexToUtf8('0x78797a')
console.log(str)
