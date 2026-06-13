import { Web3 } from 'web3'

// 部署后填入 forge script 输出的合约地址
export const storageAddress = process.env.REACT_APP_CONTRACT_ADDRESS || ''

export const storageAbi = [
  {
    inputs: [{ internalType: 'string', name: 'x', type: 'string' }],
    name: 'set',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [],
    name: 'get',
    outputs: [{ internalType: 'string', name: '', type: 'string' }],
    stateMutability: 'view',
    type: 'function',
  },
]

export function createStorageContract(web3) {
  if (!storageAddress) {
    throw new Error('请在 client/.env 中设置 REACT_APP_CONTRACT_ADDRESS（forge script 部署后获取）')
  }
  return new web3.eth.Contract(storageAbi, storageAddress)
}
