import http from 'node:http'

const IPFS_API = 'http://127.0.0.1:5001'

// 在 Node 侧转发 IPFS 请求，浏览器只访问同源 /api/ipfs，彻底避免 CORS 403
export function ipfsServerPlugin() {
  return {
    name: 'ipfs-server',
    configureServer(server) {
      server.middlewares.use((req, res, next) => {
        if (!req.url?.startsWith('/api/ipfs')) {
          next()
          return
        }

        if (req.url === '/api/ipfs/health' && req.method === 'POST') {
          checkIpfsHealth(res)
          return
        }

        if (req.url.startsWith('/api/ipfs/add') && req.method === 'POST') {
          const query = req.url.slice('/api/ipfs/add'.length) || ''
          proxyToIpfs(`/api/v0/add${query}`, req, res)
          return
        }

        res.statusCode = 404
        res.end('not found')
      })
    },
  }
}

function checkIpfsHealth(res) {
  const url = new URL('/api/v0/version', IPFS_API)
  const proxyReq = http.request(
    {
      hostname: url.hostname,
      port: url.port,
      path: url.pathname,
      method: 'POST',
    },
    (proxyRes) => {
      let body = ''
      proxyRes.on('data', (chunk) => {
        body += chunk
      })
      proxyRes.on('end', () => {
        res.statusCode = proxyRes.statusCode ?? 500
        res.setHeader('Content-Type', 'application/json')
        res.end(body)
      })
    },
  )

  proxyReq.on('error', (err) => {
    res.statusCode = 502
    res.setHeader('Content-Type', 'application/json')
    res.end(JSON.stringify({error: `IPFS 不可达: ${err.message}，请先运行: npm run ipfs:start`}))
  })

  proxyReq.end()
}

function proxyToIpfs(path, req, res) {
  const url = new URL(path, IPFS_API)
  const headers = {}

  if (req.headers['content-type']) {
    headers['content-type'] = req.headers['content-type']
  }
  if (req.headers['content-length']) {
    headers['content-length'] = req.headers['content-length']
  }

  const proxyReq = http.request(
    {
      hostname: url.hostname,
      port: url.port,
      path: url.pathname + url.search,
      method: req.method,
      headers,
    },
    (proxyRes) => {
      res.writeHead(proxyRes.statusCode ?? 500, proxyRes.headers)
      proxyRes.pipe(res)
    },
  )

  proxyReq.on('error', (err) => {
    res.statusCode = 502
    res.setHeader('Content-Type', 'application/json')
    res.end(JSON.stringify({error: `IPFS 不可达: ${err.message}，请先运行: npm run ipfs:start`}))
  })

  req.pipe(proxyReq)
}
