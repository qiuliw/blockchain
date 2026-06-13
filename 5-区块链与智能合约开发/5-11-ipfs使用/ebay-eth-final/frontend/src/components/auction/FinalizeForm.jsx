import {finalaizeAuction} from '../../services/ecommerce'
import {useContractTx} from '../../hooks/useContractTx'
import {useWeb3} from '../../hooks/useWeb3'

// #finalize-auction：结算拍卖
export default function FinalizeForm({productId, onSuccess}) {
  const {contract} = useWeb3()
  const {send, pending, message} = useContractTx(onSuccess)

  async function handleSubmit(event) {
    event.preventDefault()
    await send((from) => finalaizeAuction(contract, productId, from))
  }

  return (
    <>
      <form id="finalize-auction" className="form_pannel auction_form" onSubmit={handleSubmit}>
        <h5 className="panel_title">结算拍卖</h5>
        <div className="form_actions">
          <button className="input_sub finalize_btn" type="submit" disabled={pending}>
            {pending ? '结算中…' : '结算拍卖'}
          </button>
        </div>
      </form>
      {message && <p className="status-msg">{message}</p>}
    </>
  )
}
