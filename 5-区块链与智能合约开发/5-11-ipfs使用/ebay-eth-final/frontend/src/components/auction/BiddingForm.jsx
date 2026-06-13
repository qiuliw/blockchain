import {useState} from 'react'
import {bid} from '../../services/ecommerce'
import {useContractTx} from '../../hooks/useContractTx'
import {useWeb3} from '../../hooks/useWeb3'
import {generateBidSecret} from '../../utils/bidSecret'
import SealedBidHelp from './SealedBidHelp'

// #bidding 表单：密封竞标
export default function BiddingForm({productId, onSuccess}) {
  const {contract} = useWeb3()
  const {send, pending, message} = useContractTx(onSuccess)
  const [secretText, setSecretText] = useState(() => generateBidSecret())

  async function handleSubmit(event) {
    event.preventDefault()

    const form = event.target
    const bidAmount = form['bid-amount'].value
    const bidSend = form['bid-send-amount'].value

    const bigNumberAmount = BigInt(bidAmount)
    console.log('bigNumberAmount:', Number(bigNumberAmount))

    await send((from) =>
      bid(contract, productId, Number(bigNumberAmount), secretText, bidSend, from),
    )
  }

  return (
    <>
      <form id="bidding" className="form_pannel auction_form" onSubmit={handleSubmit}>
        <div className="panel_header">
          <h5 className="panel_title">密封竞标</h5>
          <SealedBidHelp />
        </div>
        <div className="form_group">
          <label htmlFor="bid-amount">理想出价（整数 wei）</label>
          <input id="bid-amount" name="bid-amount" type="number" required disabled={pending} />
        </div>
        <div className="form_group">
          <label htmlFor="bid-send-amount">迷惑转账金额（ETH）</label>
          <input id="bid-send-amount" name="bid-send-amount" type="text" required disabled={pending} />
        </div>
        <div className="form_group">
          <label htmlFor="secret-text">秘密字符串（揭标时必须一致）</label>
          <div className="secret_row">
            <input
              id="secret-text"
              name="secret-text"
              type="text"
              required
              disabled={pending}
              value={secretText}
              onChange={(e) => setSecretText(e.target.value)}
            />
            <button
              type="button"
              className="btn_secondary"
              disabled={pending}
              onClick={() => setSecretText(generateBidSecret())}
            >
              重新生成
            </button>
          </div>
          <p className="field_hint">请复制保存，揭标时要填同一个。</p>
        </div>
        <div className="form_actions">
          <input className="input_sub" type="submit" value={pending ? '提交中…' : '提交竞标'} disabled={pending} />
        </div>
      </form>
      {message && <p className="status-msg">{message}</p>}
    </>
  )
}
