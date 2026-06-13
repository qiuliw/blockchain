import {useState} from 'react'
import {formatTxError} from '../utils/txError'
import {useWeb3} from './useWeb3'

// 统一发送合约交易，成功后回调 reload
export function useContractTx(onSuccess) {
  const {account} = useWeb3()
  const [pending, setPending] = useState(false)
  const [message, setMessage] = useState('')

  async function send(sendFn) {
    if (!account) {
      setMessage('请先连接钱包或启动 Anvil')
      return
    }

    setPending(true)
    setMessage('交易提交中…')
    try {
      await sendFn(account)
      setMessage('操作成功')
      if (onSuccess) await onSuccess()
    } catch (e) {
      console.error(e)
      setMessage(formatTxError(e))
    } finally {
      setPending(false)
    }
  }

  return {send, pending, message, setMessage}
}
