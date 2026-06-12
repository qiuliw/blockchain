var Web3 = require('Web3')
var web3 = new Web3()

console.log('\n将wei转换为ether, Gwei, Mwei')
console.log(web3.utils.fromWei('12345567890876433', 'ether'))
console.log(web3.utils.fromWei('12345567890876433', 'Gwei'))
console.log(web3.utils.fromWei('12345567890876433', 'Mwei'))

console.log('\n转换为Wei')
console.log(web3.utils.toWei('1', 'ether'))
console.log(web3.utils.toWei('1', 'Gwei'))
console.log(web3.utils.toWei('1', 'Mwei'))
