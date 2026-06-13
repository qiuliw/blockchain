import React, {Component} from 'react'
import getWeb3 from './utils/getWeb3'
import {createStorageContract} from './eth/instance'

import './App.css'

class App extends Component {
    state = {
        storageValue: 0,
        web3: null,
        accounts: null,
        contract: null,
    }

    componentDidMount = async () => {
        try {
            // 获取网络提供者和 web3 实例
            const web3 = await getWeb3()

            // 通过 web3 获取用户账户
            const accounts = await web3.eth.getAccounts()

            // 获取合约实例
            const contract = createStorageContract(web3)

            // 将 web3、账户、合约写入 state，然后调用合约方法示例
            this.setState({web3, accounts, contract}, this.runExample)
        } catch (error) {
            alert('加载 web3、账户或合约失败，请查看控制台了解详情。')
            console.log(error)
        }
    }

    runExample = async () => {
        const {accounts, contract} = this.state

        // 向合约写入一个值，默认为 5
        await contract.methods.set(5n).send({from: accounts[0]})

        // 读取合约中的值，验证写入是否成功
        const response = await contract.methods.get().call()

        // 用读取结果更新界面
        this.setState({storageValue: Number(response)})
    }

    render() {
        if (!this.state.web3) {
            return <div>正在加载 Web3、账户和合约...</div>
        }
        return (
            <div className="App">
                <h1>一切就绪！</h1>
                <p>Foundry 合约已就绪。</p>
                <h2>智能合约示例</h2>
                <p>
                    如果合约已成功编译并部署，下方将显示存储的值（默认为 5）。
                </p>
                <p>
                    可尝试修改 <strong>App.js</strong> 中 <code>runExample</code> 里写入的值。
                </p>
                <div>当前存储的值：{this.state.storageValue}</div>
            </div>
        )
    }
}

export default App
