import {revealBid} from '../../services/ecommerce'
import {useContractTx} from '../../hooks/useContractTx'
import {useWeb3} from '../../hooks/useWeb3'

// #revealing 表单：揭标（拍卖结束后 60 秒内）
export default function RevealingForm({productId, onSuccess}) {
  const {contract} = useWeb3()
  const {send, pending, message} = useContractTx(onSuccess)

  async function handleSubmit(event) {
    event.preventDefault()

    const form = event.target
    const actualAmount = form['actual-amount'].value
    const secretText = form['reveal-secret-text'].value

    const bigNumberAmount = BigInt(actualAmount)
    console.log('bigNumberAmount:', Number(bigNumberAmount))

    await send((from) =>
      revealBid(contract, productId, Number(bigNumberAmount), secretText, from),
    )
  }

  return (
    <>
      <form id="revealing" className="form_pannel auction_form" onSubmit={handleSubmit}>
        <h5 className="panel_title">揭标（拍卖结束后 60 秒内）</h5>
        <div className="form_group">
          <label htmlFor="actual-amount">真实出价（整数 wei）</label>
          <input id="actual-amount" name="actual-amount" type="number" required disabled={pending} />
        </div>
        <div className="form_group">
          <label htmlFor="reveal-secret-text">秘密字符串</label>
          <input id="reveal-secret-text" name="reveal-secret-text" type="text" required disabled={pending} />
        </div>
        <div className="form_actions">
          <input className="input_sub" type="submit" value={pending ? '提交中…' : '揭标'} disabled={pending} />
        </div>
      </form>
      {message && <p className="status-msg">{message}</p>}
    </>
  )
}
