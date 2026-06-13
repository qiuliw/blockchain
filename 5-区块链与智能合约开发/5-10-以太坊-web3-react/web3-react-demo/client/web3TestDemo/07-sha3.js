const { Web3 } = require('web3')
const web3 = new Web3()

// web3 4.x 使用 keccak256（以太坊所称的 sha3）
var hash0 = web3.utils.keccak256('abc')
console.log(hash0)

//对结果进行再次 hash
var hash1 = web3.utils.keccak256(hash0)
console.log(hash1)
