import {env} from '../config/env'

function getApiBase() {
  // 开发环境：Vite Node 中间件 /api/ipfs（无 CORS）
  if (import.meta.env.DEV && typeof window !== 'undefined') {
    return `${window.location.origin}/api/ipfs`
  }
  return `${env.ipfs.protocol}://${env.ipfs.host}:${env.ipfs.port}/api/v0`
}

// 浏览器展示图片走网关（与旧版 IPFS_GATEWAY_URL 一致）
export function ipfsGatewayUrl(cid) {
  if (!cid) return ''
  return `${env.ipfs.gatewayUrl}/ipfs/${cid}`
}

// 检查 IPFS 是否可用
export async function checkIpfsHealth() {
  const res = await fetch(`${getApiBase()}/health`, {method: 'POST'})
  if (!res.ok) {
    const text = await res.text()
    throw new Error(`IPFS 未启动或不可访问（${res.status}）${text ? `：${text}` : ''}，请先运行: npm run ipfs:start`)
  }
  return res.json()
}

// 将图片或描述上传到 IPFS，返回 cid 字符串
export async function addToIpfs(data) {
  const form = new FormData()
  form.append('file', new Blob([data]))

  const res = await fetch(`${getApiBase()}/add?stream-channels=true&progress=false`, {
    method: 'POST',
    body: form,
  })

  if (!res.ok) {
    const text = await res.text()
    throw new Error(`IPFS 上传失败（${res.status}）：${text || res.statusText}`)
  }

  const json = await res.json()
  return json.Hash || json.Cid?.['/'] || json.cid || json.hash
}

// 从 IPFS 读取文本描述
export async function readTextFromIpfs(cid) {
  const res = await fetch(ipfsGatewayUrl(cid))
  if (!res.ok) {
    throw new Error(`IPFS 读取失败（${res.status}）`)
  }
  return res.text()
}
