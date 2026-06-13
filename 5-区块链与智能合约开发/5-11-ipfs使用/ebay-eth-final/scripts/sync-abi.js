// 将 forge build 产物转为 frontend/src/eth/abi.json，供 Vite 前端 import
const fs = require('fs')
const path = require('path')

const artifactPath = path.join(__dirname, '../out/EcommerceStore.sol/EcommerceStore.json')
const outDir = path.join(__dirname, '../frontend/src/eth')
const outPath = path.join(outDir, 'abi.json')

if (!fs.existsSync(artifactPath)) {
  console.error('请先运行: forge build')
  process.exit(1)
}

const artifact = JSON.parse(fs.readFileSync(artifactPath, 'utf8'))
fs.mkdirSync(outDir, {recursive: true})
fs.writeFileSync(outPath, JSON.stringify(artifact.abi, null, 2))
console.log('ABI synced to', outPath)
