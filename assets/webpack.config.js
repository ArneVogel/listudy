const path = require('path');
const glob = require('glob');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const TerserPlugin = require('terser-webpack-plugin');
const OptimizeCSSAssetsPlugin = require('optimize-css-assets-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');

module.exports = (env, options) => {
  const devMode = options.mode !== 'production';

  return {
    optimization: {
      minimizer: [
        new TerserPlugin({ cache: true, parallel: true, sourceMap: devMode }),
        new OptimizeCSSAssetsPlugin({})
      ]
    },
    entry: {
      'app': glob.sync('./vendor/**/*.js').concat(['./js/app.js']),
      'live_view': glob.sync('./vendor/**/*.js').concat(['./js/live_view.js']),
      'tactics': glob.sync('./vendor/**/*.js').concat(['./js/tactics.js']),
      'chessclicker': glob.sync('./vendor/**/*.js').concat(['./js/chessclicker.js']),
      'blind_tactics': glob.sync('./vendor/**/*.js').concat(['./js/blind_tactics.js']),
      'pieceless_tactics': glob.sync('./vendor/**/*.js').concat(['./js/pieceless_tactics.js']),
      'play_stockfish': glob.sync('./vendor/**/*.js').concat(['./js/play_stockfish.js']),
      'endgames': glob.sync('./vendor/**/*.js').concat(['./js/endgames.js']),
      'remember_lichess_study': glob.sync('./vendor/**/*.js').concat(['./js/remember_lichess_study.js']),
      'study': glob.sync('./vendor/**/*.js').concat(['./js/study.js'])
    },
    output: {
      filename: '[name].js',
      path: path.resolve(__dirname, '../priv/static/js'),
      publicPath: '/js/'
    },
    devtool: devMode ? 'source-map' : undefined,
    module: {
      rules: [
        {
          test: /\.js$/,
          exclude: /node_modules/,
          use: {
            loader: 'babel-loader'
          }
        },
        {
          test: /\.[s]?css$/,
          use: [
            MiniCssExtractPlugin.loader,
            'css-loader',
            'sass-loader',
          ],
        }
      ]
    },
    plugins: [
      new MiniCssExtractPlugin({ filename: '../css/[name].css' }),
      new CopyWebpackPlugin([{ from: 'static/', to: '../' }])
    ]
  }
};
