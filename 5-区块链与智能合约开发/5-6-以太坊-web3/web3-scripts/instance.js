//获取合约实例，导出去

const { Web3 } = require('web3')
const fs = require('fs')
const path = require('path')

//1. 引入web3
//2. new 一个web3实例
const web3 = new Web3('http://127.0.0.1:8545')
//3. 设置网络

const artifactPath = path.join(__dirname, 'out/SimpleStorage.sol/SimpleStorage.json')
if (!fs.existsSync(artifactPath)) {
  throw new Error('请先运行: forge build')
}
const { abi } = JSON.parse(fs.readFileSync(artifactPath, 'utf8'))

// 部署后填入 forge script 输出的合约地址
const address = ''

if (!address) {
  throw new Error('请先在 instance.js 中设置合约地址（forge script 部署后获取）')
}

//此处abi已经json对象，不需要进行parse动作
const contractInstance = new web3.eth.Contract(abi, address)

console.log('address :', contractInstance.options.address)

module.exports = contractInstance
