# frozen_string_literal: true
require 'dotenv/load'

require './lib/buyable'
require './lib/sellable'

class OrderCondition
  AMOUNT_YEN = 3000
  IS_PRODUCTION = ENV['IS_PRODUCTION'] == 'true' || false

  def initialize(price, db_client, assets, log)
    data = price[:data]
    @log = log
    @sell_price = data[:sell].to_f
    @buy_price = data[:buy].to_f
    @last_price = data[:last].to_f

    @db_client = db_client
    @last_history = last_history
    @assets = assets
  end

  def buy?
    @log << "[Buy?] ================"
    @log << "Buy Price: #{@buy_price}"
    return false if last_is_buy?
    return true if Buyable.new.should_buy?(weekly_prices, @log)
  end

  def sell?
    @log << "[Sell?] ================"
    @log << "Sell Price: #{@sell_price}"
    return false unless last_is_buy?
    return true if Sellable.new.should_sell?(weekly_prices, @last_history, @sell_price, @log)
  end

  def weekly_prices
    @db_client.get_tickers(limit: 10_080).to_a
  end

  def last_history
    last = histories.first
    @log << "last_history: #{last}"
    last
  end

  def last_is_buy?
    last_is_buy = @last_history ? @last_history[:side] == 'buy' : false
    @log << "last is buy #{last_is_buy}"

    last_is_buy
  end

  def histories
    @db_client.get_histories(limit: 5).to_a
  end

  def buy_yen
    price = @buy_price * 0.9999 # 300万なら 2,999,700
    price.to_f.floor(3)
  end

  def buy_btc_amount
    amount = AMOUNT_YEN / buy_yen # 300万なら 0.001005025
    amount.to_f.floor(8)
  end

  def sell_yen
    price = @sell_price * 1.0001 # 300万なら 3,000,300
    price.to_f.floor(3)
  end

  def sell_btc_amount
    # development mode の時は last_history を見て額を決める
    if !IS_PRODUCTION
      return @last_history[:amount].to_f.floor(8)
    end 

    # 前回買った btc を売る
    free_amount = btc_asset[:free_amount].to_f.floor(8)
    return free_amount if free_amount > 0

    return 0
  end

  def btc_asset
    btc = nil
    @assets[:data][:assets].each do |a|
      if a[:asset] == 'btc'
        btc = a
      end
    end

    btc
  end
end
