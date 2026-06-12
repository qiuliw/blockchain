const fs = require('fs')
const path = require('path')

const artifactPath = path.join(__dirname, '../out/EcommerceStore.sol/EcommerceStore.json')
const outDir = path.join(__dirname, '../abi')
const outPath = path.join(outDir, 'EcommerceStore.json')

if (!fs.existsSync(artifactPath)) {
  console.error('请先运行: forge build')
  process.exit(1)
}

const artifact = JSON.parse(fs.readFileSync(artifactPath, 'utf8'))
const exported = {
  contractName: 'EcommerceStore',
  abi: artifact.abi,
  bytecode: artifact.bytecode.object,
}

fs.mkdirSync(outDir, { recursive: true })
fs.writeFileSync(outPath, JSON.stringify(exported, null, 2))
console.log('ABI synced to', outPath)
