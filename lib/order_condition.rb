# frozen_string_literal: true

require './lib/buyable'
require './lib/sellable'

class OrderCondition
  AMOUNT_YEN = 3000

  def initialize(price, db_client)
    data = price['data']
    puts "ticker: #{data}"
    @sell_price = data['sell'].to_i
    @buy_price = data['buy'].to_i
    @last_price = data['last'].to_i

    @db_client = db_client
    @last_history = last_history
  end

  def buy?
    puts "buy? ================\n"
    return false if last_is_buy?
    return true if Buyable.new.should_buy?(weekly_prices)
  end

  def sell?
    puts "sell? ================\n"
    return false unless last_is_buy?
    return true if Sellable.new.should_sell?(weekly_prices, @last_history)
  end

  def weekly_prices
    @db_client.get_tickers(limit: 10_080).to_a
  end

  def last_history
    last = histories.last
    puts "last_history: #{last}"
    last
  end

  def last_is_buy?
    last_is_buy = @last_history ? @last_history['side'] == 'buy' : false
    puts "last is buy #{last_is_buy}"

    last_is_buy
  end

  def histories
    @db_client.get_histories(limit: 5).to_a
  end

  def buy_yen
    @buy_price * 0.995 # 300万なら 2,985,000
  end

  def buy_btc_amount
    AMOUNT_YEN / buy_yen # 300万なら 0.001005025
  end

  def sell_yen
    @sell_price * 1.003 # 300万なら 3,009,000
  end

  def sell_btc_amount
    # 前回買った btc を売る
    @last_history['amount'].to_i if @last_history['side'] == 'buy'
  end
end
