# frozen_string_literal: true

require 'dotenv/load'
require 'google/cloud/firestore'

class FirestoreClient
  FB_SECRET_FILE = ENV['FB_SECRET_FILE_ABSOLUTE_PATH']

  def initialize
    firestore = Google::Cloud::Firestore.new(
      project_id: 'bitbank-auto',
      credentials: FB_SECRET_FILE
    )

    @histories_db = firestore.col('histories')
  end

  def write_history(data)
    @histories_db.doc(Time.new).set(data)
  end
end
