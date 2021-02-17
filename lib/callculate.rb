# frozen_string_literal: true

module Callculate
  # intercept: 切片
  # slope: 傾き
  def reg_line(count, y)
    x_array = [*1..count]
    sum_x = x_array.inject(0) { |s, a| s += a }
    sum_y = y.inject(0) { |s, a| s += a }

    sum_xx = x_array.inject(0) { |s, a| s += a * a }
    sum_xy = x_array.zip(y).inject(0) { |s, a| s += a[0] * a[1] }

    a = sum_xx * sum_y - sum_xy * sum_x
    a /= (x_array.size * sum_xx - sum_x * sum_x).to_f

    b = x_array.size * sum_xy - sum_x * sum_y
    b /= (x_array.size * sum_xx - sum_x * sum_y).to_f
    { intercept: a, slope: b }
  end

  # 任意の count の reg
  # 1 count は概ね 1 分
  def calc_reg(weekly_prices, count, type)
    # weekly_prices は created_at で昇順で渡ってくる
    # 10_080 件取得しているため、一旦降順にして先頭（最も直近）から取得して、再度昇順に戻す
    data = weekly_prices.reverse[0..(count - 1)].reverse
    prices = data.map { |price| price[type]&.to_f }.compact
    reg_line(prices.count, prices)
  end

  def compare_slope(small: nil, small_name: nil, small_by: 1, big: nil, big_name: nil, big_by: 1)
    puts '[Compare Slope]'
    slope_small = small[:slope]
    slope_big = big[:slope]
    puts "#{small_name} * #{small_by} < #{big_name} * #{big_by}"
    puts "#{slope_small * small_by} < #{slope_big * big_by}"
    slope_small * small_by < slope_big * big_by
  end
end
