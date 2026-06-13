import { Web3 } from 'web3'

// 部署后填入 forge script 输出的合约地址
export const storageAddress = ''

// SimpleStorage ABI（forge build 产物）
export const storageAbi = [
  {
    inputs: [{ internalType: 'uint256', name: 'x', type: 'uint256' }],
    name: 'set',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [],
    name: 'get',
    outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
]

export function createStorageContract(web3) {
  if (!storageAddress) {
    throw new Error('请先在 src/eth/instance.js 设置 storageAddress（forge script 部署后获取）')
  }
  return new web3.eth.Contract(storageAbi, storageAddress)
}
