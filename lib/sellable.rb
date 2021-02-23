# frozen_string_literal: true

require './lib/callculate'

class Sellable
  include Callculate

  def should_sell?(weekly_prices, last_history, sell_price, log)
    @log = log
    # 買ったときよりも高い値段のときに検証する
    if last_history['price'] > sell_price
      @log << "last_history > sell_price: #{last_history['price']} > #{sell_price}"
      return true if check_regs(weekly_prices)
    end

    # 損切り
    return true if last_history['price'] < sell_price * 0.95

    # 買ったときよりも高い値段で売る
    return false
  end

  def check_regs(weekly_prices)
    last_1hour = calc_reg(weekly_prices, 60, 'sell')
    last_3days = calc_reg(weekly_prices, 4320, 'sell')
    last_7days = calc_reg(weekly_prices, 10_080, 'buy')

    @log << "last_1hour: #{last_1hour}"
    @log << "last_3days: #{last_3days}"
    @log << "last_7days: #{last_7days}"

    compare_slope(small: last_7days, small_name: '7days', small_by: 2,
                  big: last_3days, big_name: '3days', big_by: 1) &&
      compare_slope(small: last_1hour, small_name: '1hour', small_by: 1,
                    big: last_3days, big_name: '3days', big_by: 1)
  end
end
