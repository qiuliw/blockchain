import { Web3 } from 'web3'

const getWeb3 = () => {
    return new Promise((resolve, reject) => {
        // Wait for loading completion to avoid race conditions with web3 injection timing.
        window.addEventListener('load', async () => {
            // Modern dapp browsers...
            if (window.ethereum) {
                const web3 = new Web3(window.ethereum)
                try {
                    // Request account access if needed
                    await window.ethereum.request({ method: 'eth_requestAccounts' })
                    // Acccounts now exposed
                    resolve(web3)
                } catch (error) {
                    reject(error)
                }
            }
            // Legacy dapp browsers...
            else if (window.web3) {
                // Use Mist/MetaMask's provider.
                const web3 = new Web3(window.web3.currentProvider)
                console.log('Injected web3 detected.')
                resolve(web3)
            }
            // Fallback to localhost; Anvil default port
            else {
                const web3 = new Web3(process.env.REACT_APP_RPC_URL || 'http://127.0.0.1:8545')
                console.log('No web3 instance injected, using Local web3.')
                resolve(web3)
            }
        })
    })
}
export default getWeb3
