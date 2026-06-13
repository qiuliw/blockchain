import {Link, useParams} from 'react-router-dom'
import BiddingForm from '../components/auction/BiddingForm'
import EscrowPanel from '../components/auction/EscrowPanel'
import FinalizeForm from '../components/auction/FinalizeForm'
import RevealingForm from '../components/auction/RevealingForm'
import {AuctionPhase, ProductStatus} from '../constants/product'
import {useProductDetail} from '../hooks/useProductDetail'
import {useWeb3} from '../hooks/useWeb3'
import {ipfsGatewayUrl} from '../services/ipfs'
import {displayEndHours, displayPrice} from '../utils/format'

function statusText(status) {
  if (Number(status) === ProductStatus.Open) return '竞拍中'
  if (Number(status) === ProductStatus.Sold) return '已成交'
  if (Number(status) === ProductStatus.Unsold) return '未卖出'
  return '未知'
}

// 对应旧版 product.html + renderProductDetail
export default function ProductDetail() {
  const {id} = useParams()
  const {web3, ready, initError} = useWeb3()
  const {product, description, bidInfo, escrow, phase, loading, reload} = useProductDetail(id)

  if (!ready) return <p className="page_hint">正在连接区块链…</p>
  if (initError) return <p className="error-msg">初始化失败：{initError}</p>
  if (loading) return <p className="page_hint">加载中…</p>
  if (!product) return <p className="page_hint">商品不存在</p>

  const status = Number(product.status)

  return (
    <>
      <div className="breadcrumb">
        <Link to="/">首页</Link> / 商品详情
      </div>
      <div className="list_title">
        <span>商品详情</span>
      </div>

      <div id="product-details" className="product_detail">
        <div className="product_detail_left">
          <div className="left_goods_show">
            <img
              src={ipfsGatewayUrl(product.imageLink)}
              alt={product.name}
              className="product_detail_img"
            />
          </div>

          {description && (
            <div className="detail_panel product_desc_panel">
              <h5 className="panel_title">商品描述</h5>
              <div id="product-desc" className="product_desc">
                {description}
              </div>
            </div>
          )}
        </div>

        <div className="right_goods_data">
          <div className="detail_sections">
            <div className="detail_panel product_meta">
              <div className="meta_row">
                <span className="meta_label">商品名</span>
                <span className="meta_value meta_name" id="product-name">
                  {product.name}
                </span>
              </div>
              <div className="meta_row">
                <span className="meta_label">类别</span>
                <span className="meta_value">{product.category}</span>
              </div>
              <div className="meta_row">
                <span className="meta_label">起拍价</span>
                <span className="meta_value meta_price" id="product-price">
                  {displayPrice(web3, product.startPrice)}
                </span>
              </div>
              <div className="meta_row">
                <span className="meta_label">倒计时</span>
                <span className="meta_value" id="product-auction-end">
                  {displayEndHours(product.auctionEndTime)}
                </span>
              </div>
              <div className="meta_row">
                <span className="meta_label">状态</span>
                <span className="meta_value">{statusText(status)}</span>
              </div>
            </div>

            <div className="detail_actions">
          {status === ProductStatus.Open && phase === AuctionPhase.Bidding && (
            <BiddingForm productId={id} onSuccess={reload} />
          )}

          {status === ProductStatus.Open && phase === AuctionPhase.Revealing && (
            <RevealingForm productId={id} onSuccess={reload} />
          )}

          {status === ProductStatus.Open && phase === AuctionPhase.Finalize && (
            <FinalizeForm productId={id} onSuccess={reload} />
          )}

          {status === ProductStatus.Sold && escrow && (
            <EscrowPanel
              web3={web3}
              productId={id}
              bidInfo={bidInfo}
              escrow={escrow}
              onSuccess={reload}
            />
          )}

          {status === ProductStatus.Unsold && (
            <p id="product-status" className="status_banner">
              产品状态：拍卖结束，未卖出
            </p>
          )}
            </div>
          </div>
        </div>
      </div>
    </>
  )
}
