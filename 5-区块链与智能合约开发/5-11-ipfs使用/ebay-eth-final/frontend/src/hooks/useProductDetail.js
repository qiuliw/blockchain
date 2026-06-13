import {useCallback, useEffect, useState} from 'react'
import {ProductStatus} from '../constants/product'
import {fetchProductById, fetchSoldExtras} from '../services/ecommerce'
import {readTextFromIpfs} from '../services/ipfs'
import {getAuctionPhase} from '../utils/product'
import {useWeb3} from './useWeb3'

// 商品详情页：链上信息 + IPFS 描述 + 拍卖阶段
export function useProductDetail(productId) {
  const {contract, ready, initError} = useWeb3()
  const [product, setProduct] = useState(null)
  const [description, setDescription] = useState('')
  const [bidInfo, setBidInfo] = useState(null)
  const [escrow, setEscrow] = useState(null)
  const [phase, setPhase] = useState(null)
  const [loading, setLoading] = useState(true)

  const reload = useCallback(async () => {
    if (!contract || !productId) return

    setLoading(true)
    try {
      // 2. 通过 id 得到产品详情 // call() 方式
      const info = await fetchProductById(contract, productId)
      setProduct(info)
      setPhase(getAuctionPhase(info.status, info.auctionEndTime))

      // 显示文本：从 IPFS 读取 descLink
      if (info.descLink) {
        const text = await readTextFromIpfs(info.descLink)
        setDescription(text)
      } else {
        setDescription('')
      }

      setBidInfo(null)
      setEscrow(null)

      // Sold：卖了，执行了 finalize，显示 escrow 与最高出价
      if (Number(info.status) === ProductStatus.Sold) {
        const extras = await fetchSoldExtras(contract, productId)
        setBidInfo(extras.bidInfo)
        setEscrow(extras.escrow)
      }
    } catch (e) {
      console.error('加载商品详情失败', e)
    } finally {
      setLoading(false)
    }
  }, [contract, productId])

  useEffect(() => {
    reload()
  }, [reload])

  return {product, description, bidInfo, escrow, phase, loading, ready, initError, reload}
}
