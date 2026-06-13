// forge build 后将 ABI 同步到 app/eth/abi.json
const fs = require('fs')
const path = require('path')

const artifactPath = path.join(__dirname, '../out/EcommerceStore.sol/EcommerceStore.json')
const outPath = path.join(__dirname, '../app/eth/abi.json')

if (!fs.existsSync(artifactPath)) {
  console.error('请先运行: forge build')
  process.exit(1)
}

const artifact = JSON.parse(fs.readFileSync(artifactPath, 'utf8'))
fs.mkdirSync(path.dirname(outPath), { recursive: true })
fs.writeFileSync(outPath, JSON.stringify(artifact.abi, null, 2))
console.log('ABI synced to', outPath)
