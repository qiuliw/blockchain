var Web3 = require('Web3')
var web3 = new Web3()

var hash0 = web3.utils.sha3('abc')
console.log(hash0)

//对结果0x4e03657aea45a94fc7d47ba826c8d667c0d1e6e33a64a036ec44f58fa12d6c45进行hash
var hash1 = (web3.utils.sha3(hash0))
console.log(hash1)

