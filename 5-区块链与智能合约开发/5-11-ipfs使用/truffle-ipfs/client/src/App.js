import React, {Component} from "react";
import SimpleStorageContract from "./contracts/SimpleStorage.json";
import getWeb3 from "./utils/getWeb3";
import truffleContract from "truffle-contract";

import "./App.css";

import ipfsAPI from 'ipfs-api'

let ipfs = ipfsAPI('localhost', '5001', {protocol: 'http'})

class App extends Component {
    state = {
        storageValue: 0,
        web3: null,
        accounts: null,
        instance: null,
        picHash: '',
        isWriteOk: false,
        response: '',
    };

    componentWillMount = async () => {
        try {
            const web3 = await getWeb3();
            const accounts = await web3.eth.getAccounts();

            const Contract = truffleContract(SimpleStorageContract);
            Contract.setProvider(web3.currentProvider);
            const instance = await Contract.deployed();

            this.setState({web3, accounts, instance: instance});
        } catch (error) {
            // Catch any errors for any of the above operations.
            alert(
                `Failed to load web3, accounts, or contract. Check console for details.`
            );
            console.log(error);
        }
    };

    upload = (info) => {
        let reader = new FileReader()
        reader.readAsArrayBuffer(info)

        console.log('图片的信息 :', reader)
        console.log('result  :', reader.result)

        reader.onloadend = () => {
            console.log('onloadend result  :', reader.result)

            this.saveToIpfs(reader.result).then(picHash => {
                console.log('图片哈希为:', picHash)
                this.setState({picHash})
            })
        }
    }

    saveToIpfs = (input) => {
        return new Promise(async (resolve, reject) => {
            try {

                //转成buffer
                const buffer = Buffer.from(input);

                let results = await ipfs.add(buffer)
                let hash = results[0].hash;
                resolve(hash)
            } catch (e) {
                reject(e)
            }
        })
    }

    saveToEth = async () => {
        console.log('saveToEth!')
        let {instance, picHash, accounts} = this.state

        try {
            let res = await instance.set(picHash, {from: accounts[0]})
            console.log('res:', res)
            this.setState({isWriteOk: true})
        } catch (e) {
            this.setState({isWriteOk: false})
            console.log(e)
        }
    }

    getPicHash = async () => {
        let {instance, picHash, accounts} = this.state

        try {
            let response = await instance.get.call()
            console.log('response:', response)
            this.setState({response})
        } catch (e) {
            console.log(e)
        }

    }

    render() {
        //truffle的合约实例直接使用.address就可以获取地址
        //原生的api： instance.options.address
        // let {instance} = this.state
        // {/*<h1>合约地址: {instance.address}</h1>*/}
        let {picHash, isWriteOk, response} = this.state
        return (
            <div>
                <h2>请上传图片</h2>
                <div>
                    <input type='file' ref="fileid"/>
                    <button onClick={() => this.upload(this.refs.fileid.files[0])}>点击我上传到ipfs
                    </button>
                    {
                        picHash && <h2>图片已经上传到ipfs: {picHash}</h2>
                    }
                    {
                        picHash && <button onClick={() => this.saveToEth()}>点击我上传到以太坊</button>
                    }
                    {
                        isWriteOk && <button onClick={() => this.getPicHash()}>点击我获取图片</button>
                    }
                    {
                        response &&
                        <div>
                            浏览器访问结果:{"http://localhost:8080/ipfs/" + response}
                            <img src={"http://localhost:8080/ipfs/" + response}/>
                        </div>
                    }
                </div>
            </div>
        );
    }
}

export default App;
