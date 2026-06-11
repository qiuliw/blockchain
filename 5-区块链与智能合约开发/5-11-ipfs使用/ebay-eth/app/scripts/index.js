import '../styles/app.css'
import {default as Web3} from 'web3'
import {default as contract} from 'truffle-contract'
import EcommerceStoreArtifact from '../../build/contracts/EcommerceStore.json'

import $ from 'jquery'

const ecommerceStoreContract = contract(EcommerceStoreArtifact)
let ecommerceStoreInstance

const App = {
    start: async function () {
        // Bootstrap the MetaCoin abstraction for Use.
        console.log('init !!!!!')

        ecommerceStoreContract.setProvider(window.web3.currentProvider)

        ecommerceStoreInstance = await ecommerceStoreContract.deployed()

        // let accounts = await web3.eth.getAccounts()
        //
        // let res = await ecommerceStoreInstance.addProductToStore(
        //     '衣服', '服装', 'imagelink111', 'descLink222', 2018, 2019, 10, 0, {
        //         from: accounts[0]
        //     })
        //
        // console.log('res :', res)
        //
        // res = await ecommerceStoreInstance.getProductById(1)
        // console.log('res product info :', res)

        renderProducts()
    }
}


function renderProducts() {
    // 1. 获取所有的产品数量
    ecommerceStoreInstance.productIndex().then(productIndex => {
        // 注意！！
        console.log('productIndex:', productIndex)
        for (let i = 1; i <= productIndex; i++) {
            // 2. 获取每个产品的信息
            ecommerceStoreInstance.getProductById(i).then(productInfo => {
                let {0: id, 1: name, 2: category, 3: imageLink, 4: descLink, 5: auctionStartTime, 6: auctionEndTime, 7: startPrice, 8: status} = productInfo
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
                let startT = new Date(auctionStartTime * 1000)
                node.append(`<div>${startT}</div>`)
                // 竞拍结束时间
                let endT = new Date(auctionEndTime * 1000)
                node.append(`<div>${endT}</div>`)
                // 竞拍起始价格
                // 注意！！！
                // 旧版本：web3.fromWei
                // 新版本：web3.utils.fromWei(number [, unit])
                // let price = window.utils.web3.fromWei(startPrice, 'ether')
                // node.append(`<div>${price}</div>`)
                // 按钮detail
                node.append(`<a href="product.html?id=${id.c[0]}">Details</a>`)

                // 4.组合append到id="product-list中
                $('#product-list').append(node)
            })
        }
    })
}

window.App = App

window.addEventListener('load', function () {
    if (typeof web3 !== 'undefined') {
        console.warn('Injected web3')
        window.web3 = new Web3(web3.currentProvider)
    } else {
        console.warn('local web3 found!')
        window.web3 = new Web3(new Web3.providers.HttpProvider('http://127.0.0.1:9545'))
    }

    App.start()
})
