# frozen_string_literal: true

require './lib/callculate'

class Buyable
  include Callculate

  def should_buy?(weekly_prices)
    return true if check_regs(weekly_prices)
  end

  def check_regs(weekly_prices)
    last_1hour = calc_reg(weekly_prices, 60, 'buy')
    last_3days = calc_reg(weekly_prices, 4320, 'buy')
    last_7days = calc_reg(weekly_prices, 10_080, 'buy')

    puts "last_1hour: #{last_1hour}"
    puts "last_3days: #{last_3days}"
    puts "last_7days: #{last_7days}"

    compare_slope(last_7days, '7days',
                  last_1hour, '1hour',
                  big_by: 2, small_by: -0.5) &&
      compare_slope(last_3days, '3days',
                    last_1hour, '1hour',
                    big_by: 2, small_by: -1)
  end
end
