# frozen_string_literal: true

require 'ruby_bitbankcc'
require 'dotenv/load'

require './lib/order_condition'
require './lib/db'
require './lib/firestore'
require './lib/line'

class Order
  KEY = ENV['BITBANK_AUTO_KEY']
  SECRET = ENV['BITBANK_AUTO_SECRET']
  IS_PRODUCTION = ENV['IS_PRODUCTION'] == 'true' || false

  def initialize
    @log = []
    @log << "[#{Time.new}] ===================="
    @client = Bitbankcc.new(KEY, SECRET)
    @order_condition = nil
    @db_client = DB.new(is_production: IS_PRODUCTION)
    @assets = nil
    @line = Line.new
  end

  def execute!
    @log << 'Start'
    @log << "environment: #{IS_PRODUCTION ? 'production' : 'development'}"
    assets = fetch_assets
    @order_condition = OrderCondition.new(fetch_btc_price, @db_client, assets, @log)

    if @order_condition.buy?
      buy
    else
      @log << '[Do not Buy]'
    end

    if @order_condition.sell?
      sell
    else
      @log << '[Do not Sell]'
    end

    @log << "<<<<<<< End >>>>>>>\n"
    puts @log

    now = Time.new
    if now.hour % 4 == 0 && now.min == 0
     @line.notify_msg(@log)
    end
  end

  def fetch_btc_price
    res = @client.read_ticker('btc_jpy')
    price = JSON.parse(res.body, symbolize_names: true)
    @db_client.insert(:tickers, price[:data])

    price
  end

  def fetch_assets
    res = @client.read_balance
    JSON.parse(res, symbolize_names: true)
  end

  def buy
    @firestore_client = FirestoreClient.new
    @log << '<<<< Buy >>>>'
    amount = @order_condition.buy_btc_amount
    if amount == 0
      @log << "BTC amount isn't enough"
      return 
    end

    transaction = {
      side: 'buy',
      pair: 'btc_jpy',
      amount: @order_condition.buy_btc_amount,
      price: @order_condition.buy_yen,
      type: 'limit', # 指値
      is_production: IS_PRODUCTION
    }
    @log << transaction

    if IS_PRODUCTION
      @log << '[CREATE ORDER]'
      res = @client.create_order(
        transaction[:pair],
        transaction[:amount],
        transaction[:price],
        transaction[:side],
        transaction[:type],
        false
      )
      @log << res
    end

    @db_client.insert(:histories, transaction)
    @firestore_client.write_history(transaction)
    @line.notify_msg(@log)
  end

  def sell
    @firestore_client = FirestoreClient.new
    @log << '<<<< Sell >>>>'
    amount = @order_condition.sell_btc_amount
    if amount == 0
      @log << "BTC amount isn't enough"
      return 
    end

    transaction = {
      side: 'sell',
      pair: 'btc_jpy',
      amount: amount,
      price: @order_condition.sell_yen,
      type: 'limit', # 指値
      is_production: IS_PRODUCTION
    }
    @log << transaction

    if IS_PRODUCTION
      @log << '[CREATE ORDER]'
      res = @client.create_order(
        transaction[:pair],
        transaction[:amount],
        transaction[:price],
        transaction[:side],
        transaction[:type],
        false
      )
      @log << res
    end

    @db_client.insert(:histories, transaction)
    @firestore_client.write_history(transaction)
    @line.notify_msg(@log)
  end
end
