// 从 Foundry 编译产物同步 ABI，供 web3.js 脚本使用
const fs = require('fs')
const path = require('path')

const artifactPath = path.join(__dirname, '../out/SimpleStorage.sol/SimpleStorage.json')
const outDir = path.join(__dirname, '../abi')
const outPath = path.join(outDir, 'SimpleStorage.json')

if (!fs.existsSync(artifactPath)) {
  console.error('请先运行: forge build')
  process.exit(1)
}

const artifact = JSON.parse(fs.readFileSync(artifactPath, 'utf8'))
const exported = {
  contractName: 'SimpleStorage',
  abi: artifact.abi,
  bytecode: artifact.bytecode.object,
}

fs.mkdirSync(outDir, { recursive: true })
fs.writeFileSync(outPath, JSON.stringify(exported, null, 2))
console.log('ABI synced to', outPath)
