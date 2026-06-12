const instance = require('./03-instance')
const config = require('./config')

const test = async () => {
  try {
    const v1 = await instance.methods.getValue().call()
    console.log('v1:', v1)

    const res = await instance.methods.setValue('Hello HangTou').send({
      from: config.from,
      value: 0,
    })
    console.log('tx:', res.transactionHash)

    const v2 = await instance.methods.getValue().call()
    console.log('v2:', v2)
  } catch (e) {
    console.error(e)
  }
}

test()
