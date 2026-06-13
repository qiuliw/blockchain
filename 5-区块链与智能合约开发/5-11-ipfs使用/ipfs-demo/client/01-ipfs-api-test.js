require('dotenv').config()

let ipfsAPI = require('ipfs-api')

let ipfs = ipfsAPI(
    process.env.IPFS_HOST || '127.0.0.1',
    process.env.IPFS_API_PORT || '5001',
    {protocol: process.env.IPFS_PROTOCOL || 'http'}
)

//启动ipfs daemon


let ipfsTest = async () => {
    let content = ipfs.types.Buffer.from('ABC');
    let results = await ipfs.files.add(content);
    let hash = results[0].hash; // "Qm...WW"

    console.log('results :', results)
    console.log('hash  :', hash)


    let info = await ipfs.cat(hash)
    console.log('info :', info.toString())

    let files = await ipfs.ls('QmYveF5558GYajmHmtYEdxh8qwxN4tKZGdFwczcRiz6jc1')

    files.forEach(file => {
        console.log('file :', file)
    })

}

ipfsTest()
