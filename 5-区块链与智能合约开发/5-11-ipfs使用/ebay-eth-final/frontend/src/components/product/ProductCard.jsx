import {Link} from 'react-router-dom'
import {ipfsGatewayUrl} from '../../services/ipfs'
import {displayPrice} from '../../utils/format'

// 列表页单个商品卡片（对应旧版 renderProducts 里动态创建的 node）
export default function ProductCard({web3, product}) {
  return (
    <li>
      <img src={ipfsGatewayUrl(product.imageLink)} alt={product.name} width="150" />
      <h5>{product.name}</h5>
      <h5>{product.category}</h5>
      <h5>{new Date(Number(product.auctionStartTime) * 1000).toLocaleString()}</h5>
      <h5>{new Date(Number(product.auctionEndTime) * 1000).toLocaleString()}</h5>
      <h5>{displayPrice(web3, product.startPrice)}</h5>
      <Link className="detail" to={`/product/${product.id}`}>
        Details
      </Link>
    </li>
  )
}
