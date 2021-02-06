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
    last_10minutes = calc_reg(weekly_prices, 10, 'sell')
    last_3days = calc_reg(weekly_prices, 4320, 'sell')

    puts "last_10minutes: #{last_10minutes}"
    puts "last_3days: #{last_3days}"

    compare_slope(last_3days, '3days', last_10minutes, '10minutes', 0.8)
  end
end
