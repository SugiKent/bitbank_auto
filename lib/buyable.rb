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
    last_2days = calc_reg(weekly_prices, 2880, :buy)

    if last_2days[:slope] > 0
      @log << '2日移動平均が0以上なので買わない'
      return false
    end

    if last_1days[:slope] < 0
      @log << '1日移動平均がマイナスなので買わない'
      return false
    end

    if last_1hour[:slope] < 0
      @log << '1時間移動平均がマイナスなので買わない'
      return false
    end

    # 2daysはマイナス
    # 1hour,1daysはプラス
    compare_slope(small: last_2days, small_name: '2days', small_by: -1,
                  big: last_1days, big_name: '1days', big_by: 0.8) &&
      compare_slope(small: last_1days, small_name: '1days', small_by: 1,
                    big: last_1hour, big_name: '1hour', big_by: 10)
  end
end
