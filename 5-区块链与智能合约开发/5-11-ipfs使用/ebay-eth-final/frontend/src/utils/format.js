// 旧版本：web3.fromWei
// 新版本：web3.utils.fromWei(number [, unit])
export function displayPrice(web3, price) {
  return `${web3.utils.fromWei(String(price), 'ether')} ETH`
}

export function getCurrentTimeInSeconds() {
  return Math.round(new Date() / 1000)
}

export function displayEndHours(seconds) {
  const currentTime = getCurrentTimeInSeconds()
  let remainingSeconds = Number(seconds) - currentTime

  if (remainingSeconds <= 0) {
    return 'Auction has ended'
  }

  const days = Math.trunc(remainingSeconds / (24 * 60 * 60))
  remainingSeconds -= days * 24 * 60 * 60
  const hours = Math.trunc(remainingSeconds / (60 * 60))
  remainingSeconds -= hours * 60 * 60
  const minutes = Math.trunc(remainingSeconds / 60)

  if (days > 0) {
    return `Auction ends in ${days} days, ${hours} hours, ${minutes} minutes`
  }
  if (hours > 0) {
    return `Auction ends in ${hours} hours, ${minutes} minutes`
  }
  if (minutes > 0) {
    return `Auction ends in ${minutes} minutes`
  }
  return `Auction ends in ${remainingSeconds} seconds`
}
