//1. 引入web3
const { Web3 } = require('web3')

//2. new 一个web3实例
//3. 设置网络 — 使用用户钱包的 provider
const web3 = new Web3(window.ethereum)

module.exports = web3
