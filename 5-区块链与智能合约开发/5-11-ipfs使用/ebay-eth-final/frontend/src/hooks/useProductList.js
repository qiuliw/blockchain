import {useCallback, useEffect, useState} from 'react'
import {fetchAllProducts} from '../services/ecommerce'
import {useWeb3} from './useWeb3'

// 商品列表页：获取 productIndex 并逐个 getProductById
export function useProductList() {
  const {contract, ready, initError} = useWeb3()
  const [products, setProducts] = useState([])
  const [loading, setLoading] = useState(true)

  const reload = useCallback(async () => {
    if (!contract) return
    setLoading(true)
    try {
      const list = await fetchAllProducts(contract)
      setProducts(list)
    } catch (e) {
      console.error('加载商品列表失败', e)
    } finally {
      setLoading(false)
    }
  }, [contract])

  useEffect(() => {
    reload()
  }, [reload])

  return {products, loading, ready, initError, reload}
}
