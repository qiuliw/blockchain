const Web3 = require('web3')
const config = require('./config')
const { abi } = require('./abi/SimpleStorage.json')

const web3 = new Web3(config.rpcUrl)

if (!config.contractAddress) {
  throw new Error('请先在 config.js 或 CONTRACT_ADDRESS 中设置合约地址（forge script 部署后获取）')
}

const contractInstance = new web3.eth.Contract(abi, config.contractAddress)

console.log('address:', contractInstance.options.address)

module.exports = contractInstance
