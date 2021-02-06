require 'clockwork'
include Clockwork

require './lib/order'

handler do |job|
  case job
  when 'order.job'
    Order.new.execute!
  end
end

every(1.minutes, 'order.job')
