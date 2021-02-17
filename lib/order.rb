# frozen_string_literal: true

require 'ruby_bitbankcc'
require 'dotenv/load'

require './lib/order_condition'
require './lib/db'
require './lib/firestore'

class Order
  KEY = ENV['BITBANK_AUTO_KEY']
  SECRET = ENV['BITBANK_AUTO_SECRET']
  IS_PRODUCTION = ENV['IS_PRODUCTION'] == 'true' || false

  def initialize
    puts "[#{Time.new}] ===================="
    @client = Bitbankcc.new(KEY, SECRET)
    @order_condition = nil
    @db_client = DB.new
    @firestore_client = FirestoreClient.new
    @assets = nil
  end

  def execute!
    puts 'Start'
    puts "environment: #{IS_PRODUCTION ? 'production' : 'development'}"
    assets = fetch_assets
    @order_condition = OrderCondition.new(fetch_btc_price, @db_client, assets)

    if @order_condition.buy?
      buy
    else
      puts '[Do not Buy]'
    end

    if @order_condition.sell?
      sell
    else
      puts '[Do not Sell]'
    end

    puts "End\n\n"
  end

  def fetch_btc_price
    res = @client.read_ticker('btc_jpy')
    price = JSON.parse(res.body)
    @db_client.insert(:tickers, price['data'])

    price
  end

  def fetch_assets
    res = @client.read_balance
    JSON.parse(res)
  end

  def buy
    puts 'Buy'
    amount = @order_condition.buy_btc_amount
    if amount == 0
      puts "BTC amount isn't enough"
      return 
    end

    transaction = {
      side: 'buy',
      pair: 'btc_jpy',
      amount: @order_condition.buy_btc_amount,
      price: @order_condition.buy_yen,
      type: 'limit' # 指値
    }
    puts transaction

    if IS_PRODUCTION
      puts '[CREATE ORDER]'
      @client.create_order(
        transaction['pair'],
        transaction['amount'],
        transaction['price'],
        transaction['side'],
        transaction['type']
      )
    end

    @db_client.insert(:histories, transaction)
    @firestore_client.write_history(transaction)
  end

  def sell
    puts 'Sell'
    amount = @order_condition.sell_btc_amount
    if amount == 0
      puts "BTC amount isn't enough"
      return 
    end

    transaction = {
      side: 'sell',
      pair: 'btc_jpy',
      amount: amount,
      price: @order_condition.sell_yen,
      type: 'limit' # 指値
    }
    puts transaction

    if IS_PRODUCTION
      puts '[CREATE ORDER]'
      @client.create_order(
        transaction['pair'],
        transaction['amount'],
        transaction['price'],
        transaction['side'],
        transaction['type']
      )
    end

    @db_client.insert(:histories, transaction)
    @firestore_client.write_history(transaction)
  end
end
