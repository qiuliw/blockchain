import ProductCard from '../components/product/ProductCard'
import {useProductList} from '../hooks/useProductList'
import {useWeb3} from '../hooks/useWeb3'

// 对应旧版 renderProducts：首页商品列表
export default function ProductList() {
  const {web3, ready, initError} = useWeb3()
  const {products, loading} = useProductList()

  if (!ready) return <p>正在连接区块链…</p>
  if (initError) return <p className="error-msg">初始化失败：{initError}</p>

  return (
    <>
      <div className="breadcrumb">首页 / 全部商品</div>
      <div className="list_title">
        <span>商品列表</span>
      </div>

      {loading ? (
        <p>加载中…</p>
      ) : products.length === 0 ? (
        <p>暂无商品，请先上架。</p>
      ) : (
        <ul id="product-list" className="goods_list">
          {products.map((product) => (
            <ProductCard key={String(product.id)} web3={web3} product={product} />
          ))}
        </ul>
      )}
    </>
  )
}
