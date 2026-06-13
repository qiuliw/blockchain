// 集中读取 Vite 环境变量，避免页面里散落 import.meta.env
export const env = {
  rpcUrl: import.meta.env.VITE_RPC_URL || 'http://127.0.0.1:8545',
  contractAddress: import.meta.env.VITE_CONTRACT_ADDRESS || '',
  ipfs: {
    host: import.meta.env.VITE_IPFS_HOST || '127.0.0.1',
    port: import.meta.env.VITE_IPFS_PORT || '5001',
    protocol: import.meta.env.VITE_IPFS_PROTOCOL || 'http',
    gatewayUrl: import.meta.env.VITE_IPFS_GATEWAY_URL || 'http://127.0.0.1:8848',
  },
}
