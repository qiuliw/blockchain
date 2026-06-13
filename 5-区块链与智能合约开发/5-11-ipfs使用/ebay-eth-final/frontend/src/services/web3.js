import {Web3} from 'web3'
import abi from '../eth/abi.json'
import {env} from '../config/env'

// Anvil 默认链 ID
export const ANVIL_CHAIN_ID = '0x7a69'

// 创建 Web3 实例
export function createWeb3() {
  if (window.ethereum) {
    console.warn('Injected web3')
    return new Web3(window.ethereum)
  }

  console.warn('local web3 found!')
  return new Web3(env.rpcUrl)
}

// 静默查询已授权账户（不弹窗）
export async function getAuthorizedAccounts() {
  if (!window.ethereum) {
    const web3 = new Web3(env.rpcUrl)
    return web3.eth.getAccounts()
  }
  return window.ethereum.request({method: 'eth_accounts'})
}

// 请求授权（弹 MetaMask 密码/连接确认框）
export async function requestWalletAccounts() {
  if (!window.ethereum) {
    throw new Error('未检测到 MetaMask，将使用 Anvil 本地账户')
  }
  return window.ethereum.request({method: 'eth_requestAccounts'})
}

// 检查 MetaMask 是否连到 Anvil
export async function getChainId() {
  if (!window.ethereum) return null
  return window.ethereum.request({method: 'eth_chainId'})
}

export function isAnvilChain(chainId) {
  return chainId?.toLowerCase() === ANVIL_CHAIN_ID
}

// 创建 EcommerceStore 合约实例
export function createContract(web3) {
  if (!env.contractAddress) {
    throw new Error('请在 frontend/.env 中设置 VITE_CONTRACT_ADDRESS（forge script 部署后获取）')
  }
  return new web3.eth.Contract(abi, env.contractAddress)
}
