let Web3 = require('web3')

let web3 = new Web3('http://127.0.0.1:7545')

console.log('version :', web3.version)


//获取账户
let accounts
//error first callback style
//旧版本web3只支持方式一形式，不支持方式二方式三
web3.eth.getAccounts((err, res) => {
    console.log('获取账户方式一：回调函数形式')
    if (err) {
        console.log('err:', err)
    }

    // console.log(res)
})

web3.eth.getAccounts().then(res => {
    console.log('获取账户方式二：then形式')
    // console.log(res)
}).catch(e => {
    console.log(e)
})

let f = async () => {
    try {
        let accounts = await web3.eth.getAccounts()
        console.log('获取账户方式三：async/await形式')
        // console.log(accounts)

        let balance1 = await web3.eth.getBalance(accounts[0])
        console.log('balance1:', balance1)

        //balance1: Promise { <pending> }
        // let balance1 = web3.eth.getBalance(accounts[0])

        let defaultAccount = web3.eth.defaultAccount
        console.log('default:', defaultAccount)
        web3.eth.defaultAccount = accounts[2]
        console.log('new default:', web3.eth.defaultAccount)

        let defaultBlock = web3.eth.defaultBlock
        console.log('defaultBlock:', defaultBlock)


        //由账户0向账户1转10eth
        let res = await web3.eth.sendTransaction({
            // from: accounts[0], //如果不指定from，那么会使用defaultAccount的值
            to: accounts[1],
            gas: '6000000',
            value: web3.utils.toWei('10', 'ether'),
        })


        //修改defaultBlock
        // web3.eth.defaultBlock = 3
        web3.eth.defaultBlock = 'latest'
        console.log('defaultBlock:', web3.eth.defaultBlock)

        let balance2 = await web3.eth.getBalance(accounts[2])
        console.log('balance2:', balance2)

    } catch (e) {
        console.log(e)
    }
}

f()






