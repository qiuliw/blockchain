const webpack = require('webpack')
require('dotenv').config()

const DEFAULTS = {
  RPC_URL: 'http://127.0.0.1:8545',
  CONTRACT_ADDRESS: '',
  IPFS_HOST: '127.0.0.1',
  IPFS_API_PORT: '5001',
  IPFS_PROTOCOL: 'http',
  IPFS_GATEWAY_URL: 'http://127.0.0.1:8848',
}

const KEYS = Object.keys(DEFAULTS)

function defineEnvPlugin() {
  const env = KEYS.reduce((acc, key) => {
    acc[`process.env.${key}`] = JSON.stringify(process.env[key] || DEFAULTS[key])
    return acc
  }, {})
  return new webpack.DefinePlugin(env)
}

module.exports = {defineEnvPlugin, DEFAULTS}
