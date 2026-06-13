import {useState} from 'react'
import {Link, useNavigate} from 'react-router-dom'
import {addProductToStore} from '../services/ecommerce'
import {addToIpfs, checkIpfsHealth} from '../services/ipfs'
import {useWeb3} from '../hooks/useWeb3'
import {formatTxError} from '../utils/txError'

// 对应旧版 list-item.html + saveProduct / saveProductToBlockChain
export default function AddProduct() {
  const {contract, account, ready, initError} = useWeb3()
  const navigate = useNavigate()
  const [submitting, setSubmitting] = useState(false)
  const [message, setMessage] = useState('')
  const [messageType, setMessageType] = useState('info') // info | success | error

  function setStatus(text, type = 'info') {
    setMessage(text)
    setMessageType(type)
  }

  async function handleSubmit(event) {
    // 防止 form 跳转
    event.preventDefault()

    if (!account) {
      setStatus('请先连接钱包或启动 Anvil', 'error')
      return
    }

    const form = event.target
    const formData = new FormData(form)

    const name = formData.get('product-name')
    const category = formData.get('product-category')
    const startPrice = formData.get('product-price')
    const condition = formData.get('product-condition')
    const startTime = formData.get('product-auction-start')
    const duration = formData.get('product-auction-end')
    const productDescInfo = formData.get('product-description')
    const imageFile = formData.get('product-image')

    if (!imageFile || imageFile.size === 0) {
      setStatus('请选择商品图片', 'error')
      return
    }

    setSubmitting(true)
    let ipfsUploaded = false
    setStatus('正在检查 IPFS…')

    try {
      await checkIpfsHealth()
      setStatus('IPFS 连接正常', 'success')

      // 将图片与数据添加到 ipfs
      setStatus('正在上传商品图片到 IPFS…')
      const imageBuffer = await imageFile.arrayBuffer()
      const imageHash = await addToIpfs(new Uint8Array(imageBuffer))
      console.log('ipfs imageHash : ', imageHash)
      setStatus(`图片上传成功：${imageHash}`, 'success')

      // 存储的数据是产品的描述信息，而不是所有的参数！
      setStatus('正在上传商品描述到 IPFS…')
      const descHash = await addToIpfs(new TextEncoder().encode(productDescInfo))
      console.log('ipfs descHash : ', descHash)
      setStatus(`描述上传成功：${descHash}，请在 MetaMask 中确认链上交易…`, 'success')
      ipfsUploaded = true

      // 将哈希等添加到区块链
      const startTimeInSeconds = Date.parse(startTime) / 1000
      const durationInSeconds = Number(duration) * 24 * 60 * 60
      const endTimeInSeconds = startTimeInSeconds + durationInSeconds
      // let priceInEther = web3.toWei(startPrice, 'ether')

      setStatus('正在写入链上…')
      await addProductToStore(
        contract,
        {
          name,
          category,
          imageHash,
          descHash,
          startTimeInSeconds,
          endTimeInSeconds,
          startPrice,
          condition,
        },
        account,
      )

      setStatus('上架成功！即将跳转到商品列表…', 'success')
      setTimeout(() => navigate('/'), 1500)
    } catch (err) {
      console.error('addProductToStore failed:', err)
      const hint = formatTxError(err)
      if (hint === '你已取消交易' && ipfsUploaded) {
        setStatus('你已取消链上交易。图片和描述已上传 IPFS，可再次点击「上架」写入链上。', 'error')
      } else if (hint === '你已取消交易') {
        setStatus('你已取消交易', 'error')
      } else {
        setStatus(`上架失败：${hint}`, 'error')
      }
    } finally {
      setSubmitting(false)
    }
  }

  if (!ready) return <p>正在连接区块链…</p>
  if (initError) return <p className="error-msg">初始化失败：{initError}</p>

  const defaultStart = new Date()
  defaultStart.setMinutes(defaultStart.getMinutes() - defaultStart.getTimezoneOffset())
  const defaultStartValue = defaultStart.toISOString().slice(0, 16)

  return (
    <>
      <div className="breadcrumb">
        <Link to="/">首页</Link> / 上架商品
      </div>
      <div className="list_title">
        <span>上架新商品</span>
      </div>

      <form id="add-item-to-store" className="add_form" onSubmit={handleSubmit}>
        <div className="form_group">
          <label>商品名称</label>
          <input name="product-name" type="text" required />
        </div>
        <div className="form_group">
          <label>类别</label>
          <input name="product-category" type="text" required />
        </div>
        <div className="form_group">
          <label>起拍价（wei）</label>
          <input name="product-price" type="number" required />
        </div>
        <div className="form_group">
          <label>成色</label>
          <select name="product-condition" required>
            <option value="0">二手</option>
            <option value="1">全新</option>
          </select>
        </div>
        <div className="form_group">
          <label>拍卖开始时间</label>
          <input
            name="product-auction-start"
            type="datetime-local"
            defaultValue={defaultStartValue}
            required
          />
        </div>
        <div className="form_group">
          <label>拍卖天数</label>
          <input name="product-auction-end" type="number" min="1" defaultValue="1" required />
        </div>
        <div className="form_group">
          <label>商品图片</label>
          <input name="product-image" type="file" accept="image/*" required />
        </div>
        <div className="form_group">
          <label>商品描述</label>
          <textarea name="product-description" required />
        </div>
        <button className="add_btn" type="submit" disabled={submitting}>
          {submitting ? '提交中…' : '上架'}
        </button>
      </form>

      {message && (
        <p className={`status-msg ${messageType === 'success' ? 'status-success' : ''} ${messageType === 'error' ? 'error-msg' : ''}`}>
          {message}
        </p>
      )}
    </>
  )
}
