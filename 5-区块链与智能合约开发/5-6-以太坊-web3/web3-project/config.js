// 合约地址：部署后填入，或设置环境变量 CONTRACT_ADDRESS
module.exports = {
  rpcUrl: process.env.RPC_URL || 'http://127.0.0.1:8545',
  contractAddress: process.env.CONTRACT_ADDRESS || '',
  from: process.env.FROM_ACCOUNT || '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266',
}
