# frozen_string_literal: true

require './lib/callculate'

class Sellable
  include Callculate

  def should_sell?(weekly_prices, last_history)
    return true if check_regs(weekly_prices)

    # 損切り
    return true if last_history['price'] < @sell_price * 0.85
  end

  def check_regs(weekly_prices)
    last_1hour = calc_reg(weekly_prices, 60, 'sell')
    last_3days = calc_reg(weekly_prices, 4320, 'sell')
    last_7days = calc_reg(weekly_prices, 10_080, 'buy')

    puts "last_1hour: #{last_1hour}"
    puts "last_3days: #{last_3days}"
    puts "last_7days: #{last_7days}"

    compare_slope(last_3days, '3days',
                  last_7days, '7days',
                  big_by: 1, small_by: 1) &&
      compare_slope(last_3days, '3days',
                    last_1hour, '1hour',
                    big_by: 1, small_by: 1)
  end
end
