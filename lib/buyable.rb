# frozen_string_literal: true

require './lib/callculate'

class Buyable
  include Callculate

  def should_buy?(weekly_prices, log)
    @log = log
    return true if check_regs(weekly_prices)
  end

  def check_regs(weekly_prices)
    last_1hour = calc_reg(weekly_prices, 60, :buy)
    last_1days = calc_reg(weekly_prices, 1440, :buy)
    last_3days = calc_reg(weekly_prices, 4320, :buy)

    # 3日移動平均が0以上なら買わない
    if last_3days[:slope] > 0
      @log << last_3days
      @log << '3日移動平均が0以上なので買わない'
      return false
    end

    compare_slope(small: last_3days, small_name: '3days', small_by: -0.8,
                  big: last_1days, big_name: '1days', big_by: 1) &&
                 compare_slope(small: last_3days, small_name: '3days', small_by: -1.5,
                  big: last_1hour, big_name: '1hour', big_by: 1) &&
                 compare_slope(small: last_1days, small_name: '1days', small_by: 1.2,
                    big: last_1hour, big_name: '1hour', big_by: 1)
  end
end
