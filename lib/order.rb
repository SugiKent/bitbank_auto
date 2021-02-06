# frozen_string_literal: true

require 'ruby_bitbankcc'

require './lib/order_condition'
require './lib/db'

class Order
  KEY = ENV['BITBANK_AUTO_KEY']
  SECRET = ENV['BITBANK_AUTO_SECRET']

  def initialize
    @client = Bitbankcc.new(KEY, SECRET)
    @order_condition = nil
    @db_client = DB.new
  end

  def execute!
    puts 'Start'
    @order_condition = OrderCondition.new(fetch_btc_price, @db_client)

    if @order_condition.buy?
      buy
    elsif @order_condition.sell?
      sell
    end

    puts 'End'
  end

  def fetch_btc_price
    res = @client.read_ticker('btc_jpy')
    price = JSON.parse(res.body)
    @db_client.insert(:tickers, price['data'])

    price
  end

  def buy
    puts 'Buy'
    transaction = {
      side: 'buy',
      pair: 'btc_jpy',
      amount: @order_condition.buy_btc_amount,
      price: @order_condition.buy_yen,
      type: 'limit' # 指値
    }

    @db_client.insert(:histories, transaction)
  end

  def sell
    puts 'Sell'
    transaction = {
      side: 'sell',
      pair: 'btc_jpy',
      amount: @order_condition.sell_btc_amount,
      price: @order_condition.sell_yen,
      type: 'limit' # 指値
    }

    @db_client.insert(:histories, transaction)
  end
end
