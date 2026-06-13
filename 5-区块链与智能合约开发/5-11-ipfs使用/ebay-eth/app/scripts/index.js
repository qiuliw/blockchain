import '../styles/app.css'
import { Web3 } from 'web3'
import abi from '../eth/abi.json'

import $ from 'jquery'

// 部署后填入 forge script 输出的合约地址
const storeAddress = ''

let ecommerceStoreInstance

const App = {
    start: async function () {
        // Bootstrap the MetaCoin abstraction for Use.
        console.log('init !!!!!')

        if (!storeAddress) {
            throw new Error('请先在 app/scripts/index.js 设置 storeAddress')
        }

        ecommerceStoreInstance = new window.web3.eth.Contract(abi, storeAddress)

        // let accounts = await web3.eth.getAccounts()
        //
        // let res = await ecommerceStoreInstance.methods.addProductToStore(
        //     '衣服', '服装', 'imagelink111', 'descLink222', 2018, 2019, 10, 0).send({
        //         from: accounts[0]
        //     })
        //
        // console.log('res :', res)
        //
        // res = await ecommerceStoreInstance.methods.getProductById(1).call()
        // console.log('res product info :', res)

        renderProducts()
    }
}


function renderProducts() {
    // 1. 获取所有的产品数量
    ecommerceStoreInstance.methods.productIndex().call().then(productIndex => {
        // 注意！！
        console.log('productIndex:', productIndex)
        const count = Number(productIndex)
        for (let i = 1; i <= count; i++) {
            // 2. 获取每个产品的信息
            ecommerceStoreInstance.methods.getProductById(i).call().then(productInfo => {
                let id = productInfo.id || productInfo[0]
                let name = productInfo.name || productInfo[1]
                let category = productInfo.category || productInfo[2]
                let imageLink = productInfo.imageLink || productInfo[3]
                let auctionStartTime = productInfo.auctionStartTime || productInfo[5]
                let auctionEndTime = productInfo.auctionEndTime || productInfo[6]
                // 3. 每个产品创建一个node，填充数据，
                // console.table(productInfo)
                let node = $('<div/>')
                // 图片显示,我的ipfs默认端口为8848，可以去home目录下.ipfs/config中修改
                node.append(`<img src="http://localhost:8848/ipfs/${imageLink}" width="150px"/>`)
                // 名字
                node.append(`<div>${name}</div>`)
                // 类别
                node.append(`<div>${category}</div>`)
                // 竞拍起始时间
                let startT = new Date(Number(auctionStartTime) * 1000)
                node.append(`<div>${startT}</div>`)
                // 竞拍结束时间
                let endT = new Date(Number(auctionEndTime) * 1000)
                node.append(`<div>${endT}</div>`)
                // 竞拍起始价格
                // 注意！！！
                // 旧版本：web3.fromWei
                // 新版本：web3.utils.fromWei(number [, unit])
                // let price = window.web3.utils.fromWei(startPrice, 'ether')
                // node.append(`<div>${price}</div>`)
                // 按钮detail
                node.append(`<a href="product.html?id=${id}">Details</a>`)

                // 4.组合append到id="product-list中
                $('#product-list').append(node)
            })
        }
    })
}

window.App = App

window.addEventListener('load', async function () {
    if (window.ethereum) {
        console.warn('Injected web3')
        window.web3 = new Web3(window.ethereum)
        await window.ethereum.request({ method: 'eth_requestAccounts' })
    } else {
        console.warn('local web3 found!')
        window.web3 = new Web3('http://127.0.0.1:8545')
    }

    App.start()
})
