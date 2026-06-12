var Web3 = require('Web3')
var web3 = new Web3()

console.log(web3.utils.toHex('a'))
console.log(web3.utils.toHex(1234))
console.log(web3.utils.toHex({name: 'Duke'}))

//将所有传入的数据都当做字符串进行处理，然后按照ASCII的16进制返回
//如果内部有单引号，则自动转化成双引号，再在外部用单引号括起来
console.log(JSON.stringify({name: 'Duke'}))
console.log(web3.utils.toHex('{"name":"Duke"}'))

console.log(web3.utils.toHex(JSON.stringify({name: 'Duke'})))

console.log(web3.utils.toHex([1, 2, 3, 4]))
console.log(web3.utils.toHex('[1,2,3,4]'))
