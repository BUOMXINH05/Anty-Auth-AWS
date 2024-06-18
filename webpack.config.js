const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const { CleanWebpackPlugin } = require('clean-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');

module.exports = {
  entry: './frontend/src/index.js', // Điểm vào của ứng dụng
  output: {
    filename: 'bundle.js',
    path: path.resolve(__dirname, 'dist'), // Thư mục đầu ra
    publicPath: '/', // Đường dẫn công khai cho tất cả các tệp được tải lên
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader', // Sử dụng Babel để chuyển đổi mã ES6+ sang ES5
        },
      },
      {
        test: /\.css$/,
        use: [MiniCssExtractPlugin.loader, 'css-loader'], // Xử lý các tệp CSS
      },
      {
        test: /\.(png|svg|jpg|gif)$/,
        use: ['file-loader'], // Xử lý các tệp hình ảnh
      },
      {
        test: /\.html$/,
        use: ['html-loader'], // Xử lý các tệp HTML
      },
    ],
  },
  plugins: [
    new CleanWebpackPlugin(), // Xóa thư mục đầu ra trước mỗi lần build
    new HtmlWebpackPlugin({
      template: './frontend/public/index.html', // Tệp HTML gốc
      filename: 'index.html', // Tên tệp đầu ra
    }),
    new MiniCssExtractPlugin({
      filename: '[name].css',
      chunkFilename: '[id].css',
    }),
  ],
  devServer: {
    contentBase: path.join(__dirname, 'dist'),
    compress: true,
    port: 9000,
    historyApiFallback: true, // Cho phép sử dụng HTML5 History API
  },
  resolve: {
    extensions: ['.js', '.jsx'], // Phần mở rộng của các tệp sẽ được xử lý
  },
  mode: 'development', // Chế độ phát triển
};
