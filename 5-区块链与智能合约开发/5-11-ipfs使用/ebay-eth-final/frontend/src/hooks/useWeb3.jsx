import {createContext, useCallback, useContext, useEffect, useMemo, useRef, useState} from 'react'
import {
  createContract,
  createWeb3,
  getAuthorizedAccounts,
  getChainId,
  isAnvilChain,
  requestWalletAccounts,
} from '../services/web3'

const Web3Context = createContext(null)

// 全局只允许一个 eth_requestAccounts 在飞，避免 already pending
let pendingWalletRequest = null

async function requestAccountsOnce() {
  if (pendingWalletRequest) return pendingWalletRequest
  pendingWalletRequest = requestWalletAccounts().finally(() => {
    pendingWalletRequest = null
  })
  return pendingWalletRequest
}

export function Web3Provider({children}) {
  const [web3, setWeb3] = useState(null)
  const [contract, setContract] = useState(null)
  const [accounts, setAccounts] = useState([])
  const [ready, setReady] = useState(false)
  const [initError, setInitError] = useState(null)
  const [walletError, setWalletError] = useState(null)
  const [needsConnect, setNeedsConnect] = useState(false)
  const [connecting, setConnecting] = useState(false)
  const [chainId, setChainId] = useState(null)
  const initStarted = useRef(false)

  const syncWalletState = useCallback(async (accs) => {
    const instance = createWeb3()
    setWeb3(instance)
    setContract(createContract(instance))
    setAccounts(accs)
    setNeedsConnect(window.ethereum != null && accs.length === 0)

    if (window.ethereum) {
      const id = await getChainId()
      setChainId(id)
      if (accs.length > 0 && !isAnvilChain(id)) {
        setWalletError('请将 MetaMask 切换到 Anvil 本地链（Chain ID: 31337）')
      } else if (accs.length > 0) {
        setWalletError(null)
      }
    }
  }, [])

  const connectWallet = useCallback(async () => {
    if (!window.ethereum) {
      setWalletError('未检测到 MetaMask')
      return
    }

    setConnecting(true)
    setWalletError(null)
    try {
      const accs = await requestAccountsOnce()
      await syncWalletState(accs)
    } catch (e) {
      const msg = e.message || String(e)
      if (msg.includes('already pending')) {
        setWalletError('MetaMask 授权窗口已打开，请确认后等待自动连接')
      } else if (e.code === 4001) {
        setWalletError('你已取消连接钱包')
        setNeedsConnect(true)
      } else {
        setWalletError(msg)
      }
    } finally {
      setConnecting(false)
    }
  }, [syncWalletState])

  // 初始化：有 MetaMask 时自动弹授权；无 MetaMask 则直连 Anvil
  useEffect(() => {
    if (initStarted.current) return
    initStarted.current = true

    async function init() {
      console.log('init !!!!!')
      try {
        const instance = createWeb3()
        let accs = await getAuthorizedAccounts()

        if (window.ethereum) {
          setConnecting(true)
          if (accs.length === 0) {
            // 自动请求授权（弹 MetaMask）
            try {
              accs = await requestAccountsOnce()
            } catch (e) {
              const msg = e.message || String(e)
              if (msg.includes('already pending')) {
                setWalletError('MetaMask 授权窗口已打开，请确认后等待自动连接')
              } else if (e.code !== 4001) {
                setWalletError(msg)
              }
              // 用户稍后确认时，由 accountsChanged 回调更新状态
            }
          }
          setConnecting(false)
        }

        await syncWalletState(accs)
      } catch (e) {
        setInitError(e.message || String(e))
      } finally {
        setReady(true)
      }
    }

    init()
  }, [syncWalletState])

  // MetaMask 登录/切账户/切链 监听回调
  useEffect(() => {
    const provider = window.ethereum
    if (!provider?.on) return

    const onAccountsChanged = (accs) => {
      console.log('accountsChanged:', accs)
      syncWalletState(accs)
      setConnecting(false)
      if (accs.length > 0) {
        setWalletError(null)
      } else {
        setNeedsConnect(true)
        setWalletError('钱包已断开，请重新连接')
      }
    }

    const onConnect = async () => {
      console.log('ethereum connect')
      const accs = await getAuthorizedAccounts()
      await syncWalletState(accs)
      setConnecting(false)
      setWalletError(null)
    }

    const onDisconnect = () => {
      console.log('ethereum disconnect')
      setAccounts([])
      setNeedsConnect(true)
      setWalletError('钱包已断开，请重新连接')
    }

    const onChainChanged = (id) => {
      console.log('chainChanged:', id)
      setChainId(id)
      if (!isAnvilChain(id)) {
        setWalletError('请将 MetaMask 切换到 Anvil 本地链（Chain ID: 31337）')
      } else {
        setWalletError(null)
      }
    }

    provider.on('accountsChanged', onAccountsChanged)
    provider.on('connect', onConnect)
    provider.on('disconnect', onDisconnect)
    provider.on('chainChanged', onChainChanged)

    return () => {
      provider.removeListener('accountsChanged', onAccountsChanged)
      provider.removeListener('connect', onConnect)
      provider.removeListener('disconnect', onDisconnect)
      provider.removeListener('chainChanged', onChainChanged)
    }
  }, [syncWalletState])

  const value = useMemo(
    () => ({
      web3,
      contract,
      accounts,
      account: accounts[0] ?? null,
      chainId,
      ready,
      initError,
      walletError,
      needsConnect,
      connecting,
      connectWallet,
      hasMetaMask: typeof window !== 'undefined' && Boolean(window.ethereum),
    }),
    [
      web3,
      contract,
      accounts,
      chainId,
      ready,
      initError,
      walletError,
      needsConnect,
      connecting,
      connectWallet,
    ],
  )

  return <Web3Context.Provider value={value}>{children}</Web3Context.Provider>
}

export function useWeb3() {
  const ctx = useContext(Web3Context)
  if (!ctx) {
    throw new Error('useWeb3 must be used within Web3Provider')
  }
  return ctx
}
