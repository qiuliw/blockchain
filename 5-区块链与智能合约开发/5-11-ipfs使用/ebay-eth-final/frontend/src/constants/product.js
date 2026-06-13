// 产品竞标情况 status：0 --> 进行中  1 ---> 卖掉  2 ---> 没卖掉
export const ProductStatus = {
  Open: 0,
  Sold: 1,
  Unsold: 2,
}

// 拍卖阶段（仅 status === Open 时有效）
export const AuctionPhase = {
  Bidding: 'bidding',     // 竞标阶段
  Revealing: 'revealing', // 揭标阶段（结束后 60 秒内）
  Finalize: 'finalize',   // 结算阶段
}
