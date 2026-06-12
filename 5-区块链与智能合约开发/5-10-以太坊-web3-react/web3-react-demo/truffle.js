// // const path = require("path");
//
// module.exports = {
//   // See <http://truffleframework.com/docs/advanced/configuration>
//   // to customize your Truffle configuration!
//   // contracts_build_directory: path.join(__dirname, "client/src/contracts")
// };


module.exports = {
    // See <http://truffleframework.com/docs/advanced/configuration>
    // to customize your Truffle configuration!
    networks: {
        ganacheNet: { //自定义的名字，链接到ganache客户端
            host: "192.168.28.33",
            port: 7545,
            network_id: "*" // match any network
        }
    }
}
