let {bytecode, interface} = require('./01-compile')

// console.log(bytecode)
// console.log(interface)

//1. 引入web3

let Web3 = require('web3')
//2. new 一个web3实例
let web3 = new Web3()
//3. 设置网络

web3.setProvider('http://localhost:7545')

const account = '0xd5957914c31E1d785cCC58237d065Dd25C61c4D0'

console.log('version :', web3.version)
// console.log(web3.currentProvider)

//1. 拼接合约数据 interface
let contract = new web3.eth.Contract(JSON.parse(interface))

//2. 拼接bytecode
contract.deploy({
    data: bytecode, //合约的bytecode
    arguments: ['HelloWorld'] //给构造函数传递参数，使用数组
}).send({
    from: account,
    gas: '3000000', //不要用默认值，一定要写大一些， 要使用单引号
    //gasPrice: '1',
}).then(instance => {
    console.log('address :', instance.options.address)
})

