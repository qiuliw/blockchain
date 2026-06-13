import {AuctionPhase, ProductStatus} from '../constants/product'
import {getCurrentTimeInSeconds} from './format'

// 将 getProductById 返回值统一成具名字段（兼容 web3 4.x 的命名/下标两种格式）
export function parseProductInfo(productInfo) {
  return {
    id: productInfo.id ?? productInfo[0],
    name: productInfo.name ?? productInfo[1],
    category: productInfo.category ?? productInfo[2],
    imageLink: productInfo.imageLink ?? productInfo[3],
    descLink: productInfo.descLink ?? productInfo[4],
    auctionStartTime: productInfo.auctionStartTime ?? productInfo[5],
    auctionEndTime: productInfo.auctionEndTime ?? productInfo[6],
    startPrice: productInfo.startPrice ?? productInfo[7],
    status: productInfo.status ?? productInfo[8],
  }
}

// 根据链上 status 与当前时间判断应展示哪个表单
export function getAuctionPhase(status, auctionEndTime) {
  if (Number(status) !== ProductStatus.Open) {
    return null
  }

  const currentTime = getCurrentTimeInSeconds()
  const endTime = Number(auctionEndTime)

  if (currentTime < endTime) {
    return AuctionPhase.Bidding
  }
  if (currentTime < endTime + 60) {
    return AuctionPhase.Revealing
  }
  return AuctionPhase.Finalize
}
