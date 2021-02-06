# frozen_string_literal: true

require 'mongo'

class DB
  def initialize
    @client = Mongo::Client.new(['127.0.0.1:27017'], database: 'bitbank_auto')
    # @client = Mongo::Client.new([ '127.0.0.1:27017'], database: 'bitbank_auto', user: 'bitbank', password: '9ura2213r')
  end

  def insert(collection, data)
    now = Time.new
    data[:created_at] = now
    @client[collection].insert_one(data)
  end

  def get_tickers(limit: 500)
    # -1 は昇順
    @client[:tickers].find.sort(created_at: 1).limit(limit)
  end

  def get_histories(limit: 10)
    # -1 は昇順
    @client[:histories].find.sort(created_at: 1).limit(limit)
  end
end
