import {useState} from 'react'

// 密封竞标说明
const BIDDING_HELP = [
  {
    title: '密封竞标是什么？',
    body: '拍卖进行中，出价不公开。你先算出承诺哈希，链上只提交 hash 和迷惑转账金额；拍卖结束后再揭标，提交理想出价和秘密字符串，合约核对 hash 是否一致。',
  },
  {
    title: '承诺哈希',
    body: 'hash = keccak256(abi.encode(链ID, 合约地址, 商品ID, 你的地址, 理想出价, 秘密字符串))。竞标交易里只带这个 hash。',
  },
  {
    title: '理想出价（整数 wei）',
    body: '你真正愿意出的价格，以 wei 为单位。揭标时要填竞标时的同一个数。',
  },
  {
    title: '迷惑转账金额（ETH）',
    body: '竞标时实际从钱包转出的 ETH（msg.value），可以和理想出价不同。合约竞标阶段只锁定这笔钱；揭标后多退少补。',
  },
  {
    title: '秘密字符串',
    body: '你自己保管的随机量，别人猜不到。和理想出价一起算 hash；建议用页面自动生成的，揭标时必须一致。',
  },
  {
    title: '链ID / 合约 / 商品 / 地址',
    body: '写进 hash 是为了绑定这场拍卖和你的账户，防止把别处的承诺搬过来用，也防止不同输入拼出同一个 hash。',
  },
]

export default function SealedBidHelp() {
  const [open, setOpen] = useState(false)

  return (
    <div className="panel_help">
      <button
        type="button"
        className="help_btn"
        aria-label="密封竞标说明"
        aria-expanded={open}
        onClick={() => setOpen((v) => !v)}
      >
        ?
      </button>
      {open && (
        <div className="help_box" role="dialog" aria-label="密封竞标说明">
          <p className="help_intro">
            先竞标、后揭标，最高价者进入仲裁交割流程。
          </p>
          {BIDDING_HELP.map((item) => (
            <div className="help_item" key={item.title}>
              <strong>{item.title}</strong>
              <p>{item.body}</p>
            </div>
          ))}
          <p className="help_tip">提示：请保存理想出价和秘密字符串，揭标时必须一致。</p>
        </div>
      )}
    </div>
  )
}
