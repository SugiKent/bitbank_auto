# frozen_string_literal: true

require './lib/order'
require './lib/line'

line = Line.new
begin
  Order.new.execute!
rescue => e
  line.notify_msg(e)
end
