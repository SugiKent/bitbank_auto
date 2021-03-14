# frozen_string_literal: true
require 'mongo'

require './lib/order_condition'
require './lib/buyable'
require './lib/sellable'

@logs = []
@db_client = Mongo::Client.new(['127.0.0.1:27017'], database: 'bitbank_auto')
limit = 60 * 24 * 90
# 今→昔で取得
tickers = @db_client[:tickers].find.sort(created_at: -1).limit(limit).to_a
results = []

class OrderConditionTest < OrderCondition
  def initialize(price, db_client, assets, log, current_index, tickers, results)
    @current_index = current_index
    @tickers = tickers
    @results = results
    super(price, db_client, assets, log)
  end

  def weekly_prices
    # @tickers の中は今→昔
    # reverse することで昔→今にする
    # current_index は昔→今におけるindexなので、先頭~そのindexまでを取得する
    # そして再度、今→昔にする
    first_index = (@current_index - 10800 - 1) > 0 ? (@current_index - 10800 - 1) : 0
    @tickers.reverse[first_index..(@current_index - 1)].reverse
  end

  def histories
    @results.reverse
  end
end

puts "tickers count: #{tickers.count}"

# 昔から each する
tickers.reverse.each_with_index do |tic, i|
  # 計算ロジックを変えずに試行するときに、任意の時点までスキップする
  # next if i < 60 * 24 * 20

  price = {}
  price[:data] = tic
  @log = []
  order_condition = OrderConditionTest.new(price, @db_client, nil, @log, i, tickers, results)

  transaction = nil

  if order_condition.buy?
    transaction = {
      side: 'buy',
      pair: 'btc_jpy',
      amount: order_condition.buy_btc_amount,
      price: order_condition.buy_yen,
      type: 'limit' # 指値
    }

    puts "Buy"
  end

  if order_condition.sell?
    transaction = {
      side: 'sell',
      pair: 'btc_jpy',
      amount: order_condition.sell_btc_amount,
      price: order_condition.sell_yen,
      type: 'limit' # 指値
    }

    puts "Sell"
  end

  if transaction != nil
    results << transaction
  end

  if i % (60 * 24 * 2) == 0
    puts "[#{i / (60 * 24).to_f}日経過]"
    puts "results: #{results.count}"
    puts @logs.last
    @logs = []
  end

  if i > 60 * 24 * 90
    break
  end

  @logs << @log
end

value = 3000
results.each do |r|
  if r[:side] == 'buy'
    value = value - r[:price].to_i
  else
    value = value + r[:price].to_i
  end
end

puts '<<<<<< Result >>>>>>'
puts "results count: #{results.count}"
puts "value: #{value}"

