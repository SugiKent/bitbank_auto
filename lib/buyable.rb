# frozen_string_literal: true

require './lib/callculate'

class Buyable
  include Callculate

  def should_buy?(weekly_prices)
    return true if check_regs(weekly_prices)
  end

  def check_regs(weekly_prices)
    last_10minutes = calc_reg(weekly_prices, 10, 'buy')
    last_3days = calc_reg(weekly_prices, 4320, 'buy')
    last_7days = calc_reg(weekly_prices, 10_080, 'buy')

    puts "last_10minutes: #{last_10minutes}"
    puts "last_3days: #{last_3days}"
    puts "last_7days: #{last_7days}"

    compare_slope(last_10minutes, '10minutes', last_7days, '7days', 2) &&
      compare_slope(last_10minutes, '10minutes', last_3days, '3days', 1.5)
  end
end
