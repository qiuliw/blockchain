const path = require('path')
const CopyWebpackPlugin = require('copy-webpack-plugin')
const {defineEnvPlugin} = require('../../scripts/webpack-env')

module.exports = {
    entry: './app/scripts/index.js',
    mode: 'production',
    output: {
        path: path.resolve(__dirname, 'build'),
        filename: 'app.js'
    },
    plugins: [
        defineEnvPlugin(),
        new CopyWebpackPlugin([
            {from: './app/index.html', to: 'index.html'},
            {from: './app/product.html', to: 'product.html'},
            {from: './app/list-item.html', to: 'list-item.html'}
        ])
    ],
    devtool: 'source-map',
    module: {
        rules: [
            {test: /\.s?css$/, use: ['style-loader', 'css-loader', 'sass-loader']},
            {
                test: /\.js$/,
                exclude: /(node_modules|bower_components)/,
                loader: 'babel-loader',
                query: {
                    presets: ['env'],
                    plugins: ['transform-react-jsx', 'transform-object-rest-spread', 'transform-runtime']
                }
            }
        ]
    }
}
