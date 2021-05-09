# frozen_string_literal: true

require './lib/callculate'

class Sellable
  include Callculate

  def should_sell?(weekly_prices, last_history, sell_price, log)
    @log = log
    # 買ったときよりも高い値段のときに検証する
    if last_history[:price] < sell_price
      @log << "last_history > sell_price: #{last_history[:price]} > #{sell_price}"
      return true if check_regs(weekly_prices)
    end

    # 損切り
    return true if last_history[:price] < sell_price * 0.95

    return false
  end

  def check_regs(weekly_prices)
    last_1hour = calc_reg(weekly_prices, 60, :sell)
    last_1days = calc_reg(weekly_prices, 1440, :sell)
    last_3days = calc_reg(weekly_prices, 4320, :sell)
    last_5days = calc_reg(weekly_prices, 7200, :sell)

    if last_5days[:slope] < 0
      @log << '5日移動平均がマイナスなので売らない'
      return false
    end

    if last_3days[:slope] < 0
      @log << '3日移動平均がマイナスなので売らない'
      return false
    end

    if last_5days[:slope] > last_3days[:slope]
      @log << '5日移動平均が3日移動平均以上なので売らない'
      return false
    end

    if last_1days[:slope] > 0
      @log << '1日移動平均が0以上なので売らない'
      return false
    end

    if last_1hour[:slope] > 0
      @log << '1時間移動平均が0以上なので売らない'
      return false
    end

    # 5days はプラス
    # 3days はプラス
    # 1days はマイナス
    # 1hour はマイナス
    compare_slope(small: last_1days, small_name: '1days', small_by: -2,
                    big: last_3days, big_name: '3days', big_by: 1) &&
                   compare_slope(small: last_1hour, small_name: '1hour', small_by: 1.2,
                     big: last_1days, big_name: '1days', big_by: 1)
  end
end
