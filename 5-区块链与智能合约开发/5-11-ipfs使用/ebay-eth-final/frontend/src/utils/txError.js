// 将 MetaMask / web3 报错转成用户可读提示
export function formatTxError(err) {
  const code = err?.code ?? err?.cause?.code
  const msg = String(err?.message || err?.cause?.message || err || '')

  if (code === 4001 || /user denied|user rejected|rejected the request/i.test(msg)) {
    return '你已取消交易'
  }

  if (/insufficient funds/i.test(msg)) {
    return '账户余额不足，请检查 MetaMask 账户 ETH'
  }

  if (/nonce too low/i.test(msg)) {
    return '交易 nonce 冲突，请刷新页面后重试'
  }

  return msg || '未知错误'
}
