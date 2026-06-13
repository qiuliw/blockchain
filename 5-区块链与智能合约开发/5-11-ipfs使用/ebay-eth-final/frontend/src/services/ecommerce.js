import {parseProductInfo} from '../utils/product'

// 合约读写封装，页面只关心业务，不直接拼 methods 调用

export async function fetchProductIndex(contract) {
  const index = await contract.methods.productIndex().call()
  // 注意！！ productIndex 从 1 开始遍历
  return Number(index)
}

export async function fetchProductById(contract, id) {
  const raw = await contract.methods.getProductById(id).call()
  return parseProductInfo(raw)
}

export async function fetchAllProducts(contract) {
  const count = await fetchProductIndex(contract)
  const products = []
  for (let i = 1; i <= count; i++) {
    products.push(await fetchProductById(contract, i))
  }
  return products
}

// 密封竞标：先算 commitHash，再 bid 上链
export async function bid(contract, productId, bidAmount, secretText, bidSend, from) {
  const commitHash = await contract.methods
    .computeCommitHash(Number(productId), from, Number(bidAmount), secretText)
    .call()

  return contract.methods.bid(Number(productId), commitHash).send({from, value: bidSend})
}

// 揭标：真实出价 + 秘密字符串（拍卖结束后 60 秒内）
export function revealBid(contract, productId, actualAmount, secretText, from) {
  return contract.methods
    .revealBid(Number(productId), Number(actualAmount), secretText)
    .send({from})
}

// 结算拍卖（合约方法名保留拼写 finalaizeAuction）
export function finalaizeAuction(contract, productId, from) {
  return contract.methods.finalaizeAuction(Number(productId)).send({from})
}

// 仲裁投票：向卖家付款
export function giveToSeller(contract, productId, from) {
  return contract.methods.giveToSeller(Number(productId)).send({from})
}

// 仲裁投票：向买家退款
export function giveToBuyer(contract, productId, from) {
  return contract.methods.giveToBuyer(Number(productId)).send({from})
}

// 上架商品：图片/描述哈希 + 起拍时间/结束时间
export function addProductToStore(contract, params, from) {
  const {
    name,
    category,
    imageHash,
    descHash,
    startTimeInSeconds,
    endTimeInSeconds,
    startPrice,
    condition,
  } = params

  return contract.methods
    .addProductToStore(
      name,
      category,
      imageHash,
      descHash,
      startTimeInSeconds,
      endTimeInSeconds,
      startPrice,
      condition,
    )
    .send({from})
}

// Sold 状态下读取最高出价与 escrow 信息
export async function fetchSoldExtras(contract, productId) {
  const info = await contract.methods.getHighestBidInfo(productId).call()
  const bidInfo = {
    highestBidder: info[0],
    highestBid: info[1],
    secondBid: info[2],
  }

  const esc = await contract.methods.getEscrowInfo(productId).call()
  // return (buyer, seller, arbiter, buyerVotesCount, sellerVotesCount);
  const escrow = {
    buyer: esc[0],
    seller: esc[1],
    arbiter: esc[2],
    buyerVotesCount: esc[3],
    sellerVotesCount: esc[4],
  }

  return {bidInfo, escrow}
}
