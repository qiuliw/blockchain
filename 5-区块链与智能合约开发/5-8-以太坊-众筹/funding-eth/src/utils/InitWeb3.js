//1. web3
const { Web3 } = require('web3')

const web3 = new Web3(window.ethereum)
// let web3 = new Web3('http://127.0.0.1:8545')

//export导出，es6语法，default标识默认导出，在使用时，名字可以改变
//使用时，使用import
export default web3
