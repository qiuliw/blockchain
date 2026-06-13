require('dotenv').config()
const { Web3 } = require('web3')

const web3 = new Web3(process.env.RPC_URL || 'http://127.0.0.1:8545')

console.log('version :', web3.version)


//获取账户
//旧版本web3只支持回调函数形式，4.x 统一使用 Promise / async/await
web3.eth.getAccounts().then(res => {
    console.log('获取账户方式一：then形式')
}).catch(e => {
    console.log(e)
})

const f = async () => {
    try {
        const accounts = await web3.eth.getAccounts()
        console.log('获取账户方式二：async/await形式')

        const balance1 = await web3.eth.getBalance(accounts[0])
        console.log('balance1:', balance1) // bigint

        //balance1: Promise { <pending> }
        // let balance1 = web3.eth.getBalance(accounts[0])

        let defaultAccount = web3.eth.defaultAccount
        console.log('default:', defaultAccount)
        web3.eth.defaultAccount = accounts[2]
        console.log('new default:', web3.eth.defaultAccount)

        let defaultBlock = web3.eth.defaultBlock
        console.log('defaultBlock:', defaultBlock)

        //由账户0向账户1转10eth
        const res = await web3.eth.sendTransaction({
            from: accounts[0],
            to: accounts[1],
            gas: '6000000',
            value: web3.utils.toWei('10', 'ether'),
        })

        web3.eth.defaultBlock = 'latest'
        console.log('defaultBlock:', web3.eth.defaultBlock)

        const balance2 = await web3.eth.getBalance(accounts[2])
        console.log('balance2:', balance2)

    } catch (e) {
        console.log(e)
    }
}

f()
