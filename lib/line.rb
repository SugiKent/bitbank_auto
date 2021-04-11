require 'dotenv/load'

class Line
  attr_accessor :content
  def initialize
    @uri = URI.parse("https://notify-api.line.me/api/notify")
    @token = ENV['NOTIFY_TOKEN']
  end

  def notify_msg(msg)
    formated_message = msg.class == Array ? msg.join("\n") : msg
    request = make_request(formated_message)
    response = Net::HTTP.start(@uri.hostname, @uri.port, use_ssl: @uri.scheme == "https") do |https|
      https.request(request)
    end
    p response
  end

  def make_request(msg)
    request = Net::HTTP::Post.new(@uri)
    request["Authorization"] = "Bearer #{@token}"
    request.set_form_data(message: msg)
    request
  end
end
