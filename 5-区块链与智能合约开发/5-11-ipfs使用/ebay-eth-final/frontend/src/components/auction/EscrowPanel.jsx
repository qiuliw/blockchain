import {giveToBuyer, giveToSeller} from '../../services/ecommerce'
import {useContractTx} from '../../hooks/useContractTx'
import {useWeb3} from '../../hooks/useWeb3'
import {displayPrice} from '../../utils/format'

// #escrow-info：仲裁投票（2/3 票决定放款方向）
export default function EscrowPanel({web3, productId, bidInfo, escrow, onSuccess}) {
  const {contract} = useWeb3()
  const {send, pending, message} = useContractTx(onSuccess)

  // 1. 向卖家付款：调用 giveToSeller
  async function handleGiveToSeller(event) {
    event.preventDefault()
    await send((from) => giveToSeller(contract, productId, from))
  }

  // 2. 向买家退款：调用 giveToBuyer
  async function handleGiveToBuyer(event) {
    event.preventDefault()
    await send((from) => giveToBuyer(contract, productId, from))
  }

  const buyerVotes = Number(escrow.buyerVotesCount)
  const sellerVotes = Number(escrow.sellerVotesCount)

  return (
    <div id="escrow-info" className="form_pannel auction_form escrow_panel">
      <h5 className="panel_title">仲裁投票</h5>
      <div className="escrow_info">
        {bidInfo && (
          <p id="product-status">
            揭标已结束，最高价：{displayPrice(web3, bidInfo.highestBid)}，进入仲裁投票阶段
          </p>
        )}
        <p id="buyer"><span>买家</span>{escrow.buyer}</p>
        <p id="seller"><span>卖家</span>{escrow.seller}</p>
        <p id="arbiter"><span>仲裁</span>{escrow.arbiter}</p>
      </div>

      {buyerVotes === 2 ? (
        <p id="refund-count" className="status_banner">商品未成交，已退款给买家</p>
      ) : sellerVotes === 2 ? (
        <p id="release-count" className="status_banner success">
          商品成交，已付款给卖家，成交价：{bidInfo ? displayPrice(web3, bidInfo.secondBid) : ''}
        </p>
      ) : (
        <div className="form_actions escrow_actions">
          <p id="refund-count">买家获得: {escrow.buyerVotesCount}/3 票</p>
          <p id="release-count">卖家获得: {escrow.sellerVotesCount}/3 票</p>
          <button
            id="release-funds"
            className="input_sub"
            type="button"
            onClick={handleGiveToSeller}
            disabled={pending}
          >
            向卖家投票
          </button>
          <button
            id="refund-funds"
            className="input_sub secondary"
            type="button"
            onClick={handleGiveToBuyer}
            disabled={pending}
          >
            向买家投票
          </button>
        </div>
      )}
      {message && <p className="status-msg">{message}</p>}
    </div>
  )
}
