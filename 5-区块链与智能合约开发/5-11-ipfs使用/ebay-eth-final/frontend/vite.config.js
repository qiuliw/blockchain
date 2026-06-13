import {defineConfig} from 'vite'
import react from '@vitejs/plugin-react'
import {ipfsServerPlugin} from './plugins/ipfs-server.js'

export default defineConfig({
  plugins: [react(), ipfsServerPlugin()],
  server: {
    port: 5173,
    host: true,
  },
})
