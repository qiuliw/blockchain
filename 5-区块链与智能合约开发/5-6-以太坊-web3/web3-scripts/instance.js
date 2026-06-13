//获取合约实例，导出去

require('dotenv').config()

const { Web3 } = require('web3')
const fs = require('fs')
const path = require('path')

const web3 = new Web3(process.env.RPC_URL || 'http://127.0.0.1:8545')

const artifactPath = path.join(__dirname, 'out/SimpleStorage.sol/SimpleStorage.json')
if (!fs.existsSync(artifactPath)) {
  throw new Error('请先运行: forge build')
}
const { abi } = JSON.parse(fs.readFileSync(artifactPath, 'utf8'))

// 部署后填入 .env 的 CONTRACT_ADDRESS
const address = process.env.CONTRACT_ADDRESS || ''

if (!address) {
  throw new Error('请在 .env 中设置 CONTRACT_ADDRESS（forge script 部署后获取）')
}

//此处abi已经json对象，不需要进行parse动作
const contractInstance = new web3.eth.Contract(abi, address)

console.log('address :', contractInstance.options.address)

module.exports = contractInstance
