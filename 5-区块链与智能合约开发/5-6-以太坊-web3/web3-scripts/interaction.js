const instance = require('./instance')

const from = '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266'

const test = async () => {
  try {
    const v1 = await instance.methods.getValue().call()
    console.log('v1:', v1)

    const res = await instance.methods.setValue('Hello HangTou').send({
      from,
      value: 0n,
    })
    console.log('tx:', res.transactionHash)

    const v2 = await instance.methods.getValue().call()
    console.log('v2:', v2)
  } catch (e) {
    console.error(e)
  }
}

test()
