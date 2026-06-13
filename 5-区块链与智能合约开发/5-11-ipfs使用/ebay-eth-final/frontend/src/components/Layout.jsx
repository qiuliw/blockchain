import {Link} from 'react-router-dom'
import {useWeb3} from '../hooks/useWeb3'

export default function Layout({children}) {
  const {account, needsConnect, connecting, connectWallet, hasMetaMask, walletError} = useWeb3()

  return (
    <>
      <div className="top_header">
        <h2>去中心化电商拍卖</h2>
        {hasMetaMask && (
          <div className="wallet_bar">
            {account ? (
              <span className="wallet_addr">已连接：{account.slice(0, 6)}…{account.slice(-4)}</span>
            ) : (
              <button
                className="wallet_connect"
                type="button"
                onClick={connectWallet}
                disabled={connecting}
              >
                {connecting ? '等待 MetaMask 确认…' : '连接钱包'}
              </button>
            )}
          </div>
        )}
      </div>
      {connecting && !account && (
        <p className="wallet_hint">等待 MetaMask 授权确认…</p>
      )}
      {needsConnect && !account && !connecting && (
        <p className="wallet_hint">
          请连接 MetaMask 钱包。若弹窗未出现，请点击右上角「连接钱包」。
        </p>
      )}
      {walletError && <p className="error-msg wallet_hint">{walletError}</p>}
      <div className="center_wrap">
        <div className="left_con">
          <h3>商品分类</h3>
          <ul className="left_menu">
            <li>
              <Link to="/">全部商品</Link>
            </li>
          </ul>
          <Link to="/list-item" className="add_goods">
            上架商品
          </Link>
        </div>
        <div className="right_con">{children}</div>
      </div>
      <div className="footer">去中心化电商拍卖 · React 18 + Vite + Foundry</div>
    </>
  )
}
